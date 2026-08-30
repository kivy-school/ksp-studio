"""Build hook: stage the wasm bundle into the package before it is collected.

Everything about the distribution itself lives in ``pyproject.toml``.  The only
reason this file exists is that the wheel has to contain
``src/ksp_studio/web/`` — the built Swift app — and that is produced by
``scripts/build_wasm.py`` rather than checked in.  ``build_py`` is the hook
that runs early enough for the result to be picked up as package data.

    uv build --wheel        # builds the wasm, then the wheel

Set ``KSP_STUDIO_SKIP_WASM_BUILD=1`` to skip the wasm build and package
whatever is already staged.  That matters because the build needs a Swift
WebAssembly toolchain, npm and binaryen, none of which a plain
``pip install`` can assume — so CI and release machines build, and anyone
installing from an sdist without the toolchain sets the variable and gets a
server that reports the bundle is missing instead of a failed install.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

from setuptools import setup
from setuptools.command.build_py import build_py

HERE = Path(__file__).resolve().parent
BUILD_SCRIPT = HERE / "scripts" / "build_wasm.py"
STAGED_INDEX = HERE / "src" / "ksp_studio" / "web" / "index.html"
SKIP_ENV = "KSP_STUDIO_SKIP_WASM_BUILD"
# Generated trees, copied wholesale by build_py. Their filenames are
# content-hashed, so a rebuild adds rather than replaces (see prune_generated).
GENERATED = ("web", "vendor")


class BuildPyWithWasm(build_py):
    """``build_py``, preceded by a release build of the wasm app."""

    def run(self) -> None:
        self.build_wasm()
        self.prune_generated()
        super().run()

    def prune_generated(self) -> None:
        """Clear the generated trees out of setuptools' build cache first.

        ``build_py`` copies package data into ``build/lib/`` and only ever
        adds: it skips files whose timestamps match and never deletes ones
        that have gone from the source. Vite names its output by content hash,
        so every rebuild produces a *differently* named wasm — and the stale
        ones sat in ``build/lib`` and went into the wheel. Seven rebuilds made
        a 136 MB wheel holding seven 45 MiB bundles, six of them unreachable.

        Only these two directories are pruned, not all of ``build/``: they are
        the only ones whose contents are generated and renamed. Everything
        else is Python source, where a stale copy is overwritten by name.
        """
        package_root = Path(self.build_lib) / "ksp_studio"
        for name in GENERATED:
            stale = package_root / name
            if stale.is_dir():
                self.announce(f"clearing stale {stale}", level=2)
                shutil.rmtree(stale)

    def build_wasm(self) -> None:
        if os.environ.get(SKIP_ENV) == "1":
            if STAGED_INDEX.is_file():
                self.announce(f"{SKIP_ENV}=1, packaging the staged bundle", level=2)
            else:
                self.warn(
                    f"{SKIP_ENV}=1 and nothing staged in {STAGED_INDEX.parent} — "
                    "the wheel will not contain the wasm app"
                )
            return

        if not BUILD_SCRIPT.is_file():
            raise SystemExit(f"error: {BUILD_SCRIPT} is missing")

        # Release is the script's default; naming it here keeps the wheel's
        # configuration obvious at the call site rather than implied.
        self.announce(f"running {BUILD_SCRIPT.name} --release", level=2)
        try:
            subprocess.run(
                [sys.executable, str(BUILD_SCRIPT), "--release"], cwd=HERE, check=True
            )
        except subprocess.CalledProcessError as error:
            raise SystemExit(
                f"error: {BUILD_SCRIPT.name} failed with exit code {error.returncode}.\n"
                f"Set {SKIP_ENV}=1 to package without rebuilding the wasm app."
            ) from error


setup(cmdclass={"build_py": BuildPyWithWasm})
