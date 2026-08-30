"""The ksproject plugin face of the studio server.

Registers a ``studio`` root command with ``start`` / ``stop`` leaves::

    uv run ksproject studio start
    uv run ksproject studio stop

Enable it the same way as any other plugin — add the module to
``ksproject.toml`` in the project root::

    command_plugins = [
        "ksp_simple",
        "ksp_studio",
    ]

Unlike ``ksp_simple``, which hangs new leaves off the existing ``android`` /
``apple`` subcommands, this registers a new top-level one.

``start`` detaches the server and returns; ``stop`` finds it again through a
pid file.  For a server in the foreground, run ``ksp-studio`` directly — it is
the same process without the pid-file bookkeeping.
"""

from __future__ import annotations

import argparse
import errno
import os
import signal
import socket
import subprocess
import sys
import time
import webbrowser
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    # Typing-only on purpose. `CommandPlugin` is a Protocol, so nothing needs
    # it at runtime — and importing it eagerly would make the whole package
    # unimportable against a ksproject predating the plugin system (0.0.1 has
    # no `ksproject_utils.plugin`), taking the standalone `ksp-studio` server
    # down with it. `from __future__ import annotations` keeps the annotation
    # on `plugin` below from being evaluated.
    from ksproject_utils.plugin import CommandPlugin

from .project import ProjectNotFound, TargetProject

# `.kivyschool` is ksproject's project-local state directory, and `ksproject
# init` already gitignores it — the right place for a pid file nobody wants to
# commit.
STATE_DIR_NAME = ".kivyschool"
PID_FILE_NAME = "studio.pid"
LOG_FILE_NAME = "studio.log"


def _state_dir(root: Path) -> Path:
    return root / STATE_DIR_NAME


def _read_pid(pid_file: Path) -> int | None:
    """Return the pid of a live server, or None.

    A pid file left behind by a killed process is cleaned up rather than
    reported — otherwise `start` would refuse to run until it was deleted by
    hand.
    """
    try:
        pid = int(pid_file.read_text().strip())
    except (OSError, ValueError):
        return None

    try:
        os.kill(pid, 0)
    except OSError as error:
        if error.errno == errno.ESRCH:  # no such process
            pid_file.unlink(missing_ok=True)
            return None
        if error.errno == errno.EPERM:  # alive, owned by someone else
            return pid
        return None
    return pid


# A wildcard bind is reachable at the loopback address, and that is what a
# browser can actually open — "http://0.0.0.0:8000" does not work everywhere.
_WILDCARD_HOSTS = {"0.0.0.0", "::", "[::]", ""}


def _connect_host(host: str) -> str:
    return "127.0.0.1" if host in _WILDCARD_HOSTS else host


def _port_in_use(host: str, port: int) -> bool:
    """Whether something is already bound to the port.

    Checked *before* spawning, because the readiness poll below cannot tell our
    server apart from a stranger already answering on that port — without this,
    starting on a busy port reports success and hands you someone else's URL.

    Uses SO_REUSEADDR like Django's runserver does, so a socket still in
    TIME_WAIT — which runserver would happily rebind — is not mistaken for a
    live listener.
    """
    with socket.socket() as probe:
        probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            probe.bind((host, port))
        except OSError:
            return True
    return False


def _wait_until_serving(
    host: str, port: int, process: subprocess.Popen, timeout: float = 20.0
) -> bool:
    """Block until the server accepts a connection, or it dies / times out.

    Polling the port beats sleeping a fixed interval twice over: it returns as
    soon as Django is up (so the browser never races an unbound port), and it
    catches a process that stays alive without ever binding.
    """
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if process.poll() is not None:
            return False
        with socket.socket() as probe:
            probe.settimeout(0.25)
            if probe.connect_ex((_connect_host(host), port)) == 0:
                return True
        time.sleep(0.1)
    return False


class StudioCommands:

    def register(self, subparsers: argparse._SubParsersAction) -> None:
        studio = subparsers.add_parser(
            "studio", help="Run the KSProject Studio configurator UI"
        )
        studio_sub = studio.add_subparsers(dest="action", required=True)

        start = studio_sub.add_parser("start", help="Start the studio server")
        start.add_argument("--host", default="127.0.0.1", help="default: 127.0.0.1")
        start.add_argument("--port", type=int, default=8000, help="default: 8000")
        start.add_argument(
            "--no-open",
            dest="open_browser",
            action="store_false",
            help="don't open the UI in a browser",
        )
        start.set_defaults(func=self.start)

        stop = studio_sub.add_parser("stop", help="Stop the studio server")
        stop.set_defaults(func=self.stop)

    # ------------------------------------------------------------------

    def start(self, args: argparse.Namespace) -> int:
        try:
            project = TargetProject.discover()
        except ProjectNotFound as error:
            print(f"studio: {error}", file=sys.stderr)
            return 1

        state = _state_dir(project.root)
        state.mkdir(parents=True, exist_ok=True)
        pid_file = state / PID_FILE_NAME
        log_file = state / LOG_FILE_NAME

        running = _read_pid(pid_file)
        if running is not None:
            print(f"studio: already running (pid {running})")
            return 0

        if _port_in_use(args.host, args.port):
            print(
                f"studio: port {args.port} is already in use — "
                f"stop whatever is on it, or pass --port",
                file=sys.stderr,
            )
            return 1

        # start_new_session detaches from this terminal's process group, so the
        # server survives the shell that launched it and does not take Ctrl-C
        # meant for something else.
        with log_file.open("w") as log:
            process = subprocess.Popen(
                [
                    sys.executable, "-m", "ksp_studio",
                    "--host", args.host, "--port", str(args.port),
                ],
                cwd=project.root,
                stdout=log,
                stderr=subprocess.STDOUT,
                start_new_session=True,
            )

        # Report a failure (a busy port, a missing dependency) rather than a
        # success the user then can't connect to.
        if not _wait_until_serving(args.host, args.port, process):
            pid_file.unlink(missing_ok=True)
            if process.poll() is None:
                process.terminate()
                reason = f"never started listening on port {args.port}"
            else:
                reason = f"exited immediately (code {process.returncode})"
            print(f"studio: server {reason}", file=sys.stderr)
            print(f"studio: see {log_file}", file=sys.stderr)
            return 1

        url = f"http://{_connect_host(args.host)}:{args.port}"
        pid_file.write_text(str(process.pid))
        print(f"studio: editing {project.toml_path}")
        print(f"studio: {url} (pid {process.pid})")
        print(f"studio: logging to {log_file}")

        if args.open_browser:
            # Cosmetic — a headless box with no browser must not fail the
            # command that already brought the server up successfully.
            try:
                opened = webbrowser.open(url)
            except Exception:
                opened = False
            if not opened:
                print("studio: could not open a browser, visit the URL above")
        return 0

    def stop(self, args: argparse.Namespace) -> int:
        try:
            project = TargetProject.discover()
        except ProjectNotFound as error:
            print(f"studio: {error}", file=sys.stderr)
            return 1

        pid_file = _state_dir(project.root) / PID_FILE_NAME
        pid = _read_pid(pid_file)
        if pid is None:
            print("studio: not running")
            return 0

        try:
            os.kill(pid, signal.SIGTERM)
        except OSError as error:
            print(f"studio: could not stop pid {pid}: {error}", file=sys.stderr)
            return 1

        # SIGTERM is enough for runserver; escalate only if it ignores it.
        for _ in range(50):
            time.sleep(0.1)
            try:
                os.kill(pid, 0)
            except OSError:
                break
        else:
            os.kill(pid, signal.SIGKILL)

        pid_file.unlink(missing_ok=True)
        print(f"studio: stopped (pid {pid})")
        return 0


plugin: CommandPlugin = StudioCommands()
