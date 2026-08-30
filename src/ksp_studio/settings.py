"""Django settings for the studio server.

Deliberately tiny: this replaces a Vapor process that did two things — serve
the built wasm bundle and answer a JSON API — so there is no database, no
auth, no sessions and no installed apps.  It only ever binds to localhost.
"""

from __future__ import annotations

import os
from pathlib import Path

from django.core.management.utils import get_random_secret_key

# Regenerated per process. Nothing is signed across restarts (no sessions, no
# cookies), so there is no reason to persist one.
SECRET_KEY = get_random_secret_key()

DEBUG = os.environ.get("KSP_STUDIO_DEBUG", "") == "1"
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "[::1]"]

ROOT_URLCONF = "ksp_studio.urls"
WSGI_APPLICATION = "ksp_studio.wsgi.application"

INSTALLED_APPS: list[str] = []
DATABASES: dict = {}

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
]

USE_TZ = True
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# ── The wasm bundle ──
#
# `npm run build` writes KSPStudioWasm/dist/. Located, in order:
#
#   1. $KSP_STUDIO_DIST                 — explicit override
#   2. ksp_studio/web/                  — a build copied into the package
#   3. ../../KSPStudioWasm/dist         — running from a source checkout
#
# Unset when none of those exist; `views.serve_app` then explains how to build
# it rather than 404ing. In development you don't need any of this — vite
# serves the app on :5173 and proxies /api here.

_PACKAGE_DIR = Path(__file__).resolve().parent
_REPO_DIST = _PACKAGE_DIR.parent.parent / "KSPStudioWasm" / "dist"


def _find_dist() -> Path | None:
    override = os.environ.get("KSP_STUDIO_DIST")
    candidates = [Path(override)] if override else []
    candidates += [_PACKAGE_DIR / "web", _REPO_DIST]
    for candidate in candidates:
        if (candidate / "index.html").is_file():
            return candidate.resolve()
    return None


WASM_DIST_DIR = _find_dist()
