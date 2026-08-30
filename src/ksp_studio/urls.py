"""Routes.

The literal ``save`` patterns must precede the ``<str:name>`` ones — Django
matches in order and ``save`` would otherwise be swallowed as a project name.
"""

from django.urls import path, re_path

from . import views

urlpatterns = [
    # Current: one project, the directory the server was started in.
    path("api/project", views.get_project),
    path("api/project/save", views.save_project),
    # Legacy: the /api/project/:name form the wasm app inherited from the
    # Vapor server. The name is ignored (see views.get_project).
    path("api/project/<str:name>", views.get_project),
    path("api/project/<str:name>/save", views.save_project),
    # The terminal the UI opens in an iframe, plus its PTY endpoints.
    # `assets` first: it must not be read as a session id.
    path("terminal/assets/<str:filename>", views.terminal_asset),
    path("terminal", views.terminal_page),
    path("terminal/<str:session_id>/output", views.terminal_output),
    path("terminal/<str:session_id>/input", views.terminal_input),
    path("terminal/<str:session_id>/resize", views.terminal_resize),
    path("terminal/<str:session_id>/close", views.terminal_close),
    # Everything else is the wasm bundle, with an SPA fallback to index.html.
    re_path(r"^(?P<path>.*)$", views.serve_app),
]
