"""KSProject Studio — the server behind the Swift/wasm configurator UI.

Run it from the root of the ksproject you want to configure::

    cd path/to/MyApp     # the directory holding pyproject.toml
    ksp-studio

It serves the built wasm app and answers ``/api/project`` with that
``pyproject.toml``'s path and contents.

As a ksproject plugin the same server is managed in the background with
``ksproject studio start`` / ``stop`` — see ``commands.py``. The ``plugin``
symbol re-exported here is what ``ksproject_utils.plugin.load_plugins`` looks
for when ``ksproject.toml`` lists ``ksp_studio``.
"""

from __future__ import annotations

import argparse
import os
import signal
import sys

from .commands import plugin

__all__ = ["main", "plugin"]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="ksp-studio",
        description="Serve the KSProject Studio UI for the ksproject in the "
        "current directory.",
    )
    parser.add_argument("--host", default="127.0.0.1", help="default: 127.0.0.1")
    parser.add_argument("--port", default="8000", help="default: 8000")
    args = parser.parse_args(argv)

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "ksp_studio.settings")

    import django
    from django.conf import settings

    django.setup()

    # Fail here rather than on the first request — if there's no toml to edit,
    # there is nothing for the UI to do.
    from .project import ProjectNotFound, TargetProject

    try:
        project = TargetProject.discover()
    except ProjectNotFound as error:
        print(f"ksp-studio: {error}", file=sys.stderr)
        print(
            "Run it from the root of the ksproject you want to edit.",
            file=sys.stderr,
        )
        return 1

    print(f"ksp-studio: editing {project.toml_path}", flush=True)
    if settings.WASM_DIST_DIR is None:
        print(
            "ksp-studio: no wasm build found — run `npm run build` in "
            "KSPStudioWasm/, or `npm run dev` and use vite's port instead.",
            file=sys.stderr,
            flush=True,
        )

    # `ksproject studio stop` sends SIGTERM, whose default handler skips
    # atexit — which is where open terminal shells get cleaned up.
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))

    from django.core.management import execute_from_command_line

    # --noreload: the autoreloader watches this package, which is not what
    # anyone wants from an installed tool, and re-exec would repeat the
    # discovery above.
    execute_from_command_line(
        ["ksp-studio", "runserver", f"{args.host}:{args.port}", "--noreload"]
    )
    return 0
