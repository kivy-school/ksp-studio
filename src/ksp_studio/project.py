"""Locating, loading and saving the ksproject's ``pyproject.toml``.

The server is launched from the root of the ksproject it edits, so the target
is simply the working directory — there is nothing to configure and no
project picker.

This is the part that differs from the original psproject_configurator: Vapor
routed ``/project/:name`` and looked the folder up under a projects root, and
the wasm app read that name back off ``location.pathname``.  Here the project
*is* where the server was started, so it just forwards that path (and the
parsed document) to the wasm app over ``/api/project``.
"""

from __future__ import annotations

import copy
import re
import tomllib
from pathlib import Path

import tomlkit
from tomlkit.items import Comment

TOML_NAME = "pyproject.toml"


class ProjectNotFound(Exception):
    """No ``pyproject.toml`` at (or above) the directory the server started in."""


def find_project_root() -> Path:
    """Return the nearest directory containing a ``pyproject.toml``.

    Checks the working directory and then walks up, so running the server from
    a subdirectory of the ksproject still finds it.
    """
    current = Path.cwd().resolve()
    for candidate in (current, *current.parents):
        if (candidate / TOML_NAME).is_file():
            return candidate
    raise ProjectNotFound(f"no {TOML_NAME} in {current} or any parent directory")


class TargetProject:
    """The ksproject this server session is editing."""

    def __init__(self, root: Path):
        self.root = Path(root).resolve()
        self.toml_path = self.root / TOML_NAME

    @classmethod
    def discover(cls) -> "TargetProject":
        return cls(find_project_root())

    def load(self) -> dict:
        """Parse the toml into a plain dict.

        The shape is passed through untouched — it is exactly what the Swift
        ``PyProjectToml`` model expects (``project`` / ``tool.kivy-school``),
        so no translation layer is needed for the current schema.
        """
        with self.toml_path.open("rb") as f:
            return tomllib.load(f)

    def document(self) -> tomlkit.TOMLDocument:
        """Parse the toml as an editable *document*.

        Unlike :meth:`load`, this keeps everything that isn't data: key order,
        blank lines, indentation, array layout, and — the point of the whole
        exercise — comments, including the commented-out keys ksproject's
        templates ship as documentation.  ``tomlkit.dumps`` of an untouched
        document is byte-identical to what was read.
        """
        return tomlkit.parse(self.toml_path.read_text())

    def write_changes(self, changes: dict) -> bool:
        """Apply ``changes`` to the document on disk.  True if it was written.

        The whole file is never rebuilt from a dict — that is what flattened
        ``authors`` into ``[[project.authors]]``, collapsed every multi-line
        array onto one line and dropped every comment.  Instead the parsed
        document is edited in place and dumped back, so lines nobody touched
        come out exactly as they went in.

        An empty ``changes`` leaves the file alone rather than rewriting it
        with identical content.
        """
        if not changes:
            return False
        document = self.document()
        _apply_changes(document, changes)
        self.toml_path.write_text(tomlkit.dumps(document))
        return True


# ── JSON payload ──
#
# One response feeds both Swift models:
#
#   RootModel     reads `path` + `pyProject`   (the real schema — Android tab)
#   ProjectModel  reads `path` + the flat keys (the legacy bridge — Python/
#                                               Apple tabs)
#
# They nest differently (`pyProject.project` vs. a top-level `project`), so
# there is no key collision and both can be served from a single fetch.


def project_payload(project: TargetProject) -> dict:
    data = project.load()
    payload = {
        "path": str(project.root),
        "tomlPath": str(project.toml_path),
        "pyProject": data,
    }
    payload.update(_legacy_sections(data))
    return payload


def _legacy_sections(data: dict) -> dict:
    """Project the toml onto the older flat ``ProjectModel`` shape.

    Only the sections that map unambiguously are filled in.  ``_unmanaged`` /
    ``_unmanaged_keys`` came from the old Vapor server and are left empty:
    saves merge into the loaded document rather than rebuilding it, so nothing
    outside these sections is dropped and there is nothing to stash.
    """
    project = data.get("project", {})
    tool = data.get("tool", {})

    return {
        "project": {
            "name": project.get("name", ""),
            "version": project.get("version", "0.1.0"),
            "description": project.get("description", ""),
            "readme": project.get("readme", "README.md"),
            "requires-python": project.get("requires-python", ">=3.13"),
            "authors": _format_authors(project.get("authors", [])),
            "dependencies": project.get("dependencies", []),
            "scripts": project.get("scripts", {}),
        },
        "build-system": data.get("build-system", {}),
        "dependency-groups": data.get("dependency-groups", {}),
        "tool.uv": tool.get("uv", {}),
        "tool.psproject": tool.get("psproject", {}),
        "_unmanaged": "",
        "_unmanaged_keys": {},
    }


def _format_authors(authors: list) -> str:
    """Flatten toml's list-of-tables into the single string the UI edits."""
    parts = []
    for author in authors:
        if isinstance(author, dict):
            name, email = author.get("name", ""), author.get("email", "")
            parts.append(f"{name} <{email}>" if name and email else name or email)
        else:
            parts.append(str(author))
    return ", ".join(p for p in parts if p)


# ── Applying an edit ──
#
# Saving writes *differences*, not documents.  The client's models fill in a
# default for every field they know about — `presplash_color = "#FFFFFF"`,
# `copy__main__py = true`, a dozen empty lists — so posting the model back
# wholesale materialises settings the project never had, in sections it never
# had.  What arrives is therefore compared against a baseline, and only the
# keys that actually differ are touched.
#
# The baseline is supplied by the client (`_baseline`): a pristine copy of the
# same models, constructed from the same response and never handed to a view.
# That makes the comparison exact without the server having to mirror the
# client's defaults — an untouched field is identical on both sides whether it
# came from the file or from a default, so it produces no change either way.

_LEGACY_TOP_LEVEL = ("project", "build-system", "dependency-groups")
_LEGACY_TOOL = {"tool.uv": "uv", "tool.psproject": "psproject"}

#: Marks a key the edit dropped, so the merge deletes it from the document.
REMOVE = object()

#: Internal: this subtree is identical to the baseline.
_UNCHANGED = object()


def collect_changes(project: TargetProject, body: dict) -> dict:
    """Reduce a posted save to the keys it actually changes.

    The result is shaped like the document (``{"tool": {"uv": {...}}}``), with
    :data:`REMOVE` standing in for keys the edit deleted.
    """
    baseline = body.get("_baseline")
    if isinstance(baseline, dict):
        edited = {key: value for key, value in body.items() if key != "_baseline"}
        changes = _diff(_document_shape(edited), _document_shape(baseline), exact=True)
    else:
        # An older bundle, with no baseline to compare against: fall back to
        # the file itself.  Deletions can't be told apart from sections the
        # client doesn't model, so nothing is removed, and the additions that
        # can only be model defaults are refused (see ``_diff``).
        changes = _diff(_document_shape(body), project.load(), exact=False)

    return {} if changes is _UNCHANGED else changes


def _document_shape(payload: dict) -> dict:
    """Project a posted payload onto document coordinates.

    Both models can be posted together — ``pyProject`` is the real document
    (Android tab) and the flat keys are the legacy bridge (Python and Apple
    tabs), which live at ``project``, ``build-system``, ``dependency-groups``
    and under ``tool``.  Everything else in the payload (``path``,
    ``tomlPath``, ``_unmanaged*``) is metadata and is dropped here.
    """
    document: dict = {}

    py_project = payload.get("pyProject")
    if isinstance(py_project, dict):
        document = copy.deepcopy(py_project)

    for key in _LEGACY_TOP_LEVEL:
        section = payload.get(key)
        if isinstance(section, dict):
            target = document.setdefault(key, {})
            target.update(_restore_project(section) if key == "project" else section)

    for posted_key, tool_key in _LEGACY_TOOL.items():
        section = payload.get(posted_key)
        if isinstance(section, dict):
            document.setdefault("tool", {}).setdefault(tool_key, {}).update(section)

    return document


def _diff(new, old, *, exact: bool):
    """The subset of ``new`` that differs from ``old``, or :data:`_UNCHANGED`.

    ``exact`` says the two sides came from the same model, so a key missing
    from ``new`` is a deletion, and a key missing from ``old`` is a real
    addition.  Without it ``old`` is the file: absence means nothing, because
    the file holds plenty the client never models and the client holds plenty
    the file never had.

    So the inexact pass adds no table the document doesn't already have, and
    no key whose value carries no information.  That is what stops a save from
    an older bundle writing out a `[tool.psproject]` full of defaults for a
    project that has no such section.  It can still edit anything it can see,
    and still add entries to tables that exist.
    """
    if not isinstance(new, dict) or not isinstance(old, dict):
        return new if new != old else _UNCHANGED

    changes = {}
    for key, value in new.items():
        if key not in old:
            if exact or not (_is_empty(value) or isinstance(value, dict)):
                changes[key] = value
            continue
        subtree = _diff(value, old[key], exact=exact)
        if subtree is not _UNCHANGED:
            changes[key] = subtree

    if exact:
        for key in old:
            if key not in new:
                changes[key] = REMOVE

    return changes or _UNCHANGED


def _is_empty(value) -> bool:
    """A value carrying no information — a model default rather than an edit."""
    return value is None or value == "" or value == [] or value == {}


# ── Merging into the document ──


def _apply_changes(table, changes: dict) -> None:
    for key, value in changes.items():
        # `None` is the same instruction as REMOVE. TOML has no null, and the
        # client's optional fields serialise as JSON `null` when they're unset
        # — an `Optional<String>` path whose toggle is off arrives as
        # `"ndk_path": null`, meaning the key should not be in the file.
        if value is REMOVE or value is None:
            if key in table:
                del table[key]
            continue

        if isinstance(value, dict):
            current = table.get(key)
            if isinstance(current, dict):
                _apply_changes(current, value)
                continue
        elif isinstance(value, list):
            value = _array_like(table.get(key), value)

        if key in table:
            table[key] = value
        elif not _set_beside_comment(table, key, value):
            table[key] = value


def _set_beside_comment(table, key: str, value) -> bool:
    """Add a new key next to the commented-out line documenting it, if any.

    ksproject's templates ship the optional settings as commented-out examples
    — `# sdk_path = "/path/to/android-sdk"` and friends.  Appended to the end
    of the table instead, a newly enabled `sdk_path` lands ~30 lines below the
    line that documents it, under commented-out *sub-table* headers
    (`# [tool.kivy-school.android.meta_data]`), where it reads as though it
    belongs to some other section.  Slotting it in right beneath its own
    example is where a reader would go looking for it — and is what makes
    turning the toggle on look like it did something.

    The comment itself is left alone: uncommenting in place would mean
    deleting the example value the template is there to show.
    """
    container = getattr(table, "value", table)
    body = getattr(container, "body", None)
    if body is None:
        return False

    documented = re.compile(rf"^#\s*{re.escape(key)}\s*=")
    for index, (item_key, item) in enumerate(body):
        if item_key is not None or not isinstance(item, Comment):
            continue
        if documented.match(item.trivia.comment or ""):
            container._insert_at(index + 1, key, value)
            return True
    return False


def _array_like(current, values: list):
    """Rebuild an array, keeping the layout the old one had.

    Assigning a plain list gives tomlkit a single-line array, which would
    reflow a hand-formatted `dependencies = [\\n    "kivy>=2.3.1",\\n]` onto
    one line the first time anything in that table is edited.  The rendered
    form of the existing array is the only reliable tell — a manually
    line-broken array doesn't set tomlkit's own multiline flag.
    """
    array = tomlkit.array()
    array.extend(_inline_table(v) if isinstance(v, dict) else v for v in values)
    try:
        if current is not None and "\n" in current.as_string():
            array.multiline(True)
    except AttributeError:
        pass  # not a tomlkit array (a new key, or a plain list) — plain it is
    return array


def _inline_table(value: dict):
    """``{ name = "…", email = "…" }`` rather than a table of its own.

    Only reached for a dict *inside* an array — ``authors``, in practice.
    Built explicitly because handing the raw dict to ``Array.extend`` renders
    it without the separating spaces.
    """
    table = tomlkit.inline_table()
    table.update(value)
    return table


def _restore_project(section: dict) -> dict:
    """Undo the ``authors`` flattening ``_legacy_sections`` applies.

    Every other ``[project]`` key round-trips as-is.
    """
    restored = dict(section)
    if isinstance(restored.get("authors"), str):
        restored["authors"] = _parse_authors(restored["authors"])
    return restored


def _parse_authors(authors: str) -> list[dict]:
    parsed = []
    for entry in (e.strip() for e in authors.split(",")):
        if not entry:
            continue
        if "<" in entry and entry.endswith(">"):
            name, _, email = entry.partition("<")
            parsed.append({"name": name.strip(), "email": email[:-1].strip()})
        else:
            parsed.append({"name": entry})
    return parsed
