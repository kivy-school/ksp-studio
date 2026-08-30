"""A real shell, in the browser, running in the project directory.

Replaces the Vapor server's ``/terminal?path=…`` route: the UI opens that URL
in an iframe (see ``TerminalModal`` in ``ProjectConfigApp.swift``) and the
server runs an actual process on the other end.

The process is a PTY-backed login shell, so curses programs, colours and
line editing work the way they do in a normal terminal — anything else and
``uv sync`` or ``ksproject android simple`` would be unreadable.

Transport is HTTP polling rather than a WebSocket, deliberately: the server
runs under ``manage.py runserver`` (WSGI, threaded), and WebSockets would drag
in ASGI plus Channels or uvicorn to change how the whole server is launched.
Polling every 120 ms is imperceptible over loopback and keeps the dependency
list at zero.

Sessions live in this module, so they die with the server process — which is
correct: a shell outliving the server it was opened from would be a leak
nothing ever cleans up.
"""

from __future__ import annotations

import atexit
import fcntl
import os
import pty
import secrets
import signal
import struct
import termios
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path

# Enough scrollback to read a failed build, bounded so a runaway process
# can't grow the server's memory without limit.
MAX_BUFFER_CHARS = 400_000
READ_CHUNK = 65_536
IDLE_TIMEOUT_SECONDS = 60 * 60


@dataclass
class TerminalSession:
    """One PTY and the shell running on it."""

    id: str
    pid: int
    fd: int
    cwd: str
    started: float = field(default_factory=time.monotonic)
    last_seen: float = field(default_factory=time.monotonic)

    _buffer: str = ""
    # Total characters ever produced. Clients poll with the offset they last
    # saw; keeping an absolute count means trimming the buffer never makes
    # their offsets ambiguous.
    _produced: int = 0
    _lock: threading.Lock = field(default_factory=threading.Lock)
    _closed: bool = False

    # ------------------------------------------------------------------

    def start_reader(self) -> None:
        thread = threading.Thread(target=self._read_loop, daemon=True)
        thread.start()

    def _read_loop(self) -> None:
        while True:
            try:
                data = os.read(self.fd, READ_CHUNK)
            except OSError:
                # EIO is how a PTY reports that the child has exited.
                break
            if not data:
                break
            text = data.decode("utf-8", errors="replace")
            with self._lock:
                self._buffer += text
                self._produced += len(text)
                if len(self._buffer) > MAX_BUFFER_CHARS:
                    self._buffer = self._buffer[-MAX_BUFFER_CHARS:]
        with self._lock:
            self._closed = True

    # ------------------------------------------------------------------

    def read_since(self, offset: int) -> tuple[str, int]:
        """Return output produced after ``offset``, plus the new offset.

        An offset older than the trimmed buffer yields whatever is still held
        rather than an error — the client just sees a gap, which beats
        breaking the session.
        """
        with self._lock:
            self.last_seen = time.monotonic()
            buffer_start = self._produced - len(self._buffer)
            start = max(0, min(offset, self._produced) - buffer_start)
            return self._buffer[start:], self._produced

    def write(self, data: str) -> None:
        with self._lock:
            self.last_seen = time.monotonic()
        os.write(self.fd, data.encode("utf-8"))

    def resize(self, rows: int, cols: int) -> None:
        # TIOCSWINSZ is what makes the shell (and anything it runs) wrap at the
        # right width; without it everything assumes 80x24.
        size = struct.pack("HHHH", rows, cols, 0, 0)
        fcntl.ioctl(self.fd, termios.TIOCSWINSZ, size)

    @property
    def running(self) -> bool:
        with self._lock:
            if self._closed:
                return False
        try:
            pid, _ = os.waitpid(self.pid, os.WNOHANG)
        except ChildProcessError:
            return False
        return pid == 0

    def close(self) -> None:
        try:
            os.killpg(os.getpgid(self.pid), signal.SIGHUP)
        except OSError:
            pass
        try:
            os.close(self.fd)
        except OSError:
            pass
        with self._lock:
            self._closed = True


# ── Registry ──

_sessions: dict[str, TerminalSession] = {}
_registry_lock = threading.Lock()


def create_session(cwd: Path) -> TerminalSession:
    shell = os.environ.get("SHELL") or "/bin/sh"
    session_id = secrets.token_urlsafe(24)

    pid, fd = pty.fork()
    if pid == 0:
        # Child. Nothing here may raise back into the parent's world — on any
        # failure exec never happens, so exit rather than return and let a
        # forked copy of the server keep running.
        try:
            os.chdir(cwd)
            os.environ["TERM"] = "xterm-256color"
            os.execvp(shell, [shell, "-l"])
        except BaseException:
            os._exit(1)

    session = TerminalSession(id=session_id, pid=pid, fd=fd, cwd=str(cwd))
    session.start_reader()
    with _registry_lock:
        _reap_locked()
        _sessions[session_id] = session
    return session


def get_session(session_id: str) -> TerminalSession | None:
    with _registry_lock:
        return _sessions.get(session_id)


def close_session(session_id: str) -> bool:
    with _registry_lock:
        session = _sessions.pop(session_id, None)
    if session is None:
        return False
    session.close()
    return True


def _reap_locked() -> None:
    """Drop sessions whose shell has exited or that nobody has polled in an hour."""
    now = time.monotonic()
    for session_id, session in list(_sessions.items()):
        idle = now - session.last_seen > IDLE_TIMEOUT_SECONDS
        if idle or not session.running:
            _sessions.pop(session_id, None)
            session.close()


def shutdown_all() -> None:
    with _registry_lock:
        sessions = list(_sessions.values())
        _sessions.clear()
    for session in sessions:
        session.close()


# In practice a shell dies on its own when the server exits and the PTY master
# closes under it — but only once it next touches the terminal, so an idle one
# can outlive us. `main()` turns SIGTERM into a normal exit so this runs when
# `ksproject studio stop` takes the server down.
atexit.register(shutdown_all)


def is_loopback(address: str) -> bool:
    """Whether a request came from this machine.

    The terminal is arbitrary code execution by design, so it is refused for
    anyone else regardless of what ``--host`` the server was bound to. Binding
    to 0.0.0.0 to reach the *UI* from a phone must not hand the shell out with
    it.
    """
    return address in {"127.0.0.1", "::1", "localhost"}


def resolve_cwd(requested: str | None, project_root: Path) -> Path:
    """Where to start the shell.

    The UI passes the project path back as a query parameter. It is honoured
    only if it stays inside the project, so a crafted iframe URL can't open a
    shell somewhere else on the disk.
    """
    if not requested:
        return project_root
    try:
        candidate = Path(requested).resolve()
        candidate.relative_to(project_root.resolve())
    except (OSError, ValueError):
        return project_root
    return candidate if candidate.is_dir() else project_root
