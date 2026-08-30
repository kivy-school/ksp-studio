#!/usr/bin/env python3
"""Build the wasm app and stage it where the Django server looks for it.

    python scripts/build_wasm.py              # release (the default)
    python scripts/build_wasm.py --debug

Runs vite's build in ``KSPStudioWasm/`` and copies the result into
``src/ksp_studio/web/``.

``--release`` builds Swift with ``-c release`` and then runs the wasm through
``wasm-opt -Os --strip-debug``, which is what drops unreferenced code and the
debug sections.  It is the only configuration worth shipping in a wheel.
``--debug`` builds ``-c debug`` and skips wasm-opt, for when you need a
traceable binary — expect it to be substantially larger and slower.

That destination is deliberate.  ``ksp_studio.settings`` checks three places
for the bundle — ``$KSP_STUDIO_DIST``, then ``src/ksp_studio/web/``, then
``KSPStudioWasm/dist/`` — and only the middle one lives inside the Python
package, so it is also what ends up in the wheel.  Running this script is
therefore the step that makes ``pip install ksp-studio`` ship a working UI
rather than one that 503s asking to be built.

``KSPStudioWasm/dist/`` still works for a source checkout, so during
development you can just use ``npm run build`` (or ``npm run dev``) and skip
this entirely.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
WASM_DIR = REPO_ROOT / "KSPStudioWasm"
DIST_DIR = WASM_DIR / "dist"
STAGED_DIR = REPO_ROOT / "src" / "ksp_studio" / "web"
VENDOR_DIR = REPO_ROOT / "src" / "ksp_studio" / "vendor"

# xterm.js, for the browser terminal. Copied out of node_modules into the
# package rather than loaded from a CDN, so an installed wheel works offline.
# These are UMD builds — no bundling step, the page just script-tags them.
VENDORED = {
    "xterm.js": "@xterm/xterm/lib/xterm.js",
    "xterm.css": "@xterm/xterm/css/xterm.css",
    "addon-fit.js": "@xterm/addon-fit/lib/addon-fit.js",
}

# Read by vite.config.ts, which is the only place that can reach the plugin's
# build settings — see the comment there.
CONFIGURATION_ENV = "KSP_WASM_CONFIGURATION"


def run(command: list[str], cwd: Path, env: dict[str, str] | None = None) -> None:
    print(f"$ {' '.join(command)}", flush=True)
    try:
        subprocess.run(command, cwd=cwd, check=True, env=env)
    except FileNotFoundError:
        sys.exit(f"error: {command[0]} not found on PATH")
    except subprocess.CalledProcessError as error:
        sys.exit(f"error: {' '.join(command)} failed with exit code {error.returncode}")


def build(configuration: str) -> None:
    if not WASM_DIR.is_dir():
        sys.exit(f"error: {WASM_DIR} is missing (did you clone with --recursive?)")

    # `npm run build` shells out to swiftly, so a missing toolchain surfaces
    # from vite rather than here.
    if not (WASM_DIR / "node_modules").is_dir():
        run(["npm", "install"], cwd=WASM_DIR)

    if configuration == "release" and shutil.which("wasm-opt") is None:
        # The plugin only warns and carries on, and the warning is easy to miss
        # in vite's output — but the result is an unoptimized binary shipped as
        # if it were a release one.
        sys.exit(
            "error: wasm-opt not found on PATH, so a release build would not be "
            "optimized.\n"
            "Install binaryen (`brew install binaryen`), or use --debug."
        )

    print(f"building {configuration}", flush=True)
    run(
        ["npm", "run", "build"],
        cwd=WASM_DIR,
        env={**os.environ, CONFIGURATION_ENV: configuration},
    )


def stage() -> None:
    if not (DIST_DIR / "index.html").is_file():
        sys.exit(f"error: no build to stage — {DIST_DIR / 'index.html'} is missing")

    # Replaced wholesale: a stale hashed asset left behind from an earlier
    # build would be dead weight in the wheel.
    if STAGED_DIR.exists():
        shutil.rmtree(STAGED_DIR)
    shutil.copytree(DIST_DIR, STAGED_DIR)

    files = sorted(p for p in STAGED_DIR.rglob("*") if p.is_file())
    total = sum(p.stat().st_size for p in files)
    print(f"\nstaged {len(files)} files ({total / 1_048_576:.1f} MiB) in {STAGED_DIR}")
    for path in files:
        print(f"  {path.relative_to(STAGED_DIR)}  {path.stat().st_size / 1_048_576:.1f} MiB")


def vendor() -> None:
    """Copy xterm.js's dist files into the package.

    Kept separate from ``stage()`` because it is not part of the wasm bundle:
    the terminal page loads these directly from the package, so it works the
    same whether the app is being served from ``web/`` or from a source
    checkout's ``KSPStudioWasm/dist/``.
    """
    modules = WASM_DIR / "node_modules"
    if not modules.is_dir():
        sys.exit(
            f"error: {modules} is missing — run this without --skip-build, or "
            f"`npm install` in {WASM_DIR}"
        )

    VENDOR_DIR.mkdir(parents=True, exist_ok=True)
    for name, source in VENDORED.items():
        path = modules / source
        if not path.is_file():
            sys.exit(f"error: {path} is missing — try `npm install` in {WASM_DIR}")
        shutil.copy2(path, VENDOR_DIR / name)

    total = sum((VENDOR_DIR / name).stat().st_size for name in VENDORED)
    print(f"vendored {len(VENDORED)} files ({total / 1024:.0f} KiB) in {VENDOR_DIR}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="build_wasm.py",
        description="Build the wasm app and stage it where the Django server "
        "looks for it.",
    )
    configuration = parser.add_mutually_exclusive_group()
    configuration.add_argument(
        "--release",
        dest="configuration",
        action="store_const",
        const="release",
        help="build -c release and run wasm-opt -Os --strip-debug (default)",
    )
    configuration.add_argument(
        "--debug",
        dest="configuration",
        action="store_const",
        const="debug",
        help="build -c debug and skip wasm-opt",
    )
    parser.set_defaults(configuration="release")
    parser.add_argument(
        "--skip-build",
        action="store_true",
        help="stage the existing KSPStudioWasm/dist/ without rebuilding it",
    )
    args = parser.parse_args(argv)

    if not args.skip_build:
        build(args.configuration)
    stage()
    vendor()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
