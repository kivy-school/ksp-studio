"""The two things the server does: answer the project API, serve the wasm app."""

from __future__ import annotations

import json
import mimetypes
from pathlib import Path

from django.conf import settings
from django.core.serializers.json import DjangoJSONEncoder
from django.http import Http404, HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET, require_POST
from django.views.static import serve as serve_static

from . import terminal
from .project import ProjectNotFound, TargetProject, collect_changes, project_payload

# Python's mimetypes doesn't know these, and the browser refuses to
# instantiate a wasm module served as anything but application/wasm.
mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("text/javascript", ".mjs")


def _target() -> TargetProject:
    """The ksproject this server is editing.

    Resolved per request rather than cached at startup so that editing or
    creating the toml is picked up by a reload in the UI.
    """
    return TargetProject.discover()


def _not_found(error: ProjectNotFound) -> JsonResponse:
    return JsonResponse(
        {
            "status": "error",
            "message": (
                f"{error} — start ksp-studio from the root of the ksproject "
                f"you want to edit."
            ),
        },
        status=404,
    )


# ── JSON API ──
#
# `name` is accepted but ignored: the original Vapor server addressed one of
# many projects as /api/project/:name, and the wasm app still sends whatever
# it parsed out of location.pathname. There is only ever one project here —
# the directory the server was started in — so the segment is vestigial. It
# stays routed so an older bundle keeps working.


@require_GET
def get_project(request, name: str | None = None) -> JsonResponse:
    try:
        payload = project_payload(_target())
    except ProjectNotFound as error:
        return _not_found(error)
    # DjangoJSONEncoder covers the date/datetime values toml can carry.
    return JsonResponse(payload, encoder=DjangoJSONEncoder)


@csrf_exempt  # localhost-only tool, no cookies or sessions to protect
@require_POST
def save_project(request, name: str | None = None) -> JsonResponse:
    try:
        project = _target()
    except ProjectNotFound as error:
        return _not_found(error)

    try:
        body = json.loads(request.body)
    except json.JSONDecodeError as error:
        return JsonResponse(
            {"status": "error", "message": f"invalid JSON body: {error}"}, status=400
        )
    if not isinstance(body, dict):
        return JsonResponse(
            {"status": "error", "message": "expected a JSON object"}, status=400
        )

    try:
        written = project.write_changes(collect_changes(project, body))
    except OSError as error:
        return JsonResponse(
            {"status": "error", "message": f"could not write {project.toml_path}: {error}"},
            status=500,
        )

    if not written:
        return JsonResponse({"status": "ok", "message": "No changes to save"})
    return JsonResponse({"status": "ok", "message": f"Saved {project.toml_path.name}"})


# ── Terminal ──
#
# The Vapor server exposed `/terminal?path=…` and ran a real process behind it;
# this is the same contract. See `terminal.py` for the PTY and why the
# transport is polling rather than a WebSocket.

TERMINAL_PAGE = Path(__file__).resolve().parent / "terminal.html"
VENDOR_DIR = Path(__file__).resolve().parent / "vendor"
# Whitelisted rather than globbed, so the URL can never name a path of its own.
VENDOR_FILES = {"xterm.js", "xterm.css", "addon-fit.js"}


@require_GET
def terminal_asset(request, filename: str) -> HttpResponse:
    """Serve xterm.js out of the package.

    Not part of the wasm bundle in `web/`, so the terminal works the same
    whether the app is being served from a wheel or a source checkout.
    """
    if filename not in VENDOR_FILES:
        raise Http404(filename)
    return serve_static(request, filename, document_root=VENDOR_DIR)


def _terminal_forbidden(request) -> HttpResponse | None:
    """Refuse the terminal to anyone who isn't on this machine.

    Serving the UI on 0.0.0.0 to reach it from another device is reasonable;
    handing out a shell with it is not. This is checked per request rather
    than at bind time so the two decisions stay separate.
    """
    if terminal.is_loopback(request.META.get("REMOTE_ADDR", "")):
        return None
    return HttpResponse(
        "The terminal is only available from this machine.\n",
        content_type="text/plain",
        status=403,
    )


@require_GET
def terminal_page(request) -> HttpResponse:
    forbidden = _terminal_forbidden(request)
    if forbidden is not None:
        return forbidden

    try:
        project = _target()
    except ProjectNotFound as error:
        return HttpResponse(f"{error}\n", content_type="text/plain", status=404)

    if not (VENDOR_DIR / "xterm.js").is_file():
        return HttpResponse(
            "The terminal's assets are missing.\n\n"
            "Run `python scripts/build_wasm.py` to stage xterm.js into the "
            "package.\n",
            content_type="text/plain",
            status=503,
        )

    cwd = terminal.resolve_cwd(request.GET.get("path"), project.root)
    session = terminal.create_session(cwd)

    page = TERMINAL_PAGE.read_text()
    # The session id is minted per page load and is unguessable, so it doubles
    # as the capability that authorises the input/output endpoints.
    bootstrap = (
        f"<script>window.__KSP_TERMINAL__="
        f"{json.dumps({'id': session.id, 'cwd': str(cwd)})};</script>"
    )
    return HttpResponse(page.replace("<script>", bootstrap + "<script>", 1))


def _session_or_404(request, session_id: str):
    session = terminal.get_session(session_id)
    if session is None:
        return None, JsonResponse({"error": "no such session"}, status=404)
    return session, None


@require_GET
def terminal_output(request, session_id: str) -> JsonResponse:
    forbidden = _terminal_forbidden(request)
    if forbidden is not None:
        return JsonResponse({"error": "forbidden"}, status=403)

    session, error = _session_or_404(request, session_id)
    if error is not None:
        return error

    try:
        offset = int(request.GET.get("offset", 0))
    except ValueError:
        offset = 0
    data, new_offset = session.read_since(offset)
    return JsonResponse({"data": data, "offset": new_offset, "running": session.running})


@csrf_exempt  # authorised by the unguessable session id, not a cookie
@require_POST
def terminal_input(request, session_id: str) -> JsonResponse:
    forbidden = _terminal_forbidden(request)
    if forbidden is not None:
        return JsonResponse({"error": "forbidden"}, status=403)

    session, error = _session_or_404(request, session_id)
    if error is not None:
        return error

    try:
        data = json.loads(request.body).get("data", "")
    except (json.JSONDecodeError, AttributeError):
        return JsonResponse({"error": "invalid body"}, status=400)

    try:
        session.write(data)
    except OSError:
        return JsonResponse({"error": "shell has exited"}, status=409)
    return JsonResponse({"status": "ok"})


@csrf_exempt
@require_POST
def terminal_resize(request, session_id: str) -> JsonResponse:
    forbidden = _terminal_forbidden(request)
    if forbidden is not None:
        return JsonResponse({"error": "forbidden"}, status=403)

    session, error = _session_or_404(request, session_id)
    if error is not None:
        return error

    try:
        body = json.loads(request.body)
        session.resize(int(body["rows"]), int(body["cols"]))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        return JsonResponse({"error": "invalid body"}, status=400)
    except OSError:
        return JsonResponse({"error": "shell has exited"}, status=409)
    return JsonResponse({"status": "ok"})


@csrf_exempt
@require_POST
def terminal_close(request, session_id: str) -> JsonResponse:
    # Reached via navigator.sendBeacon when the modal closes.
    terminal.close_session(session_id)
    return JsonResponse({"status": "ok"})


# ── The wasm app ──


def serve_app(request, path: str = "") -> HttpResponse:
    """Serve the built bundle, falling back to index.html for app routes."""
    dist: Path | None = settings.WASM_DIST_DIR
    if dist is None:
        return HttpResponse(
            "No wasm build found.\n\n"
            "Build it with `npm run build` in KSPStudioWasm/, or point "
            "KSP_STUDIO_DIST at an existing dist/ directory.\n\n"
            "For development, run `npm run dev` instead — vite serves the app "
            "and proxies /api to this server.\n",
            content_type="text/plain",
            status=503,
        )

    if path and not path.endswith("/"):
        try:
            return serve_static(request, path, document_root=dist)
        except Http404:
            pass
    return serve_static(request, "index.html", document_root=dist)
