# ksp-studio

A GUI configurator for [KSProject](https://github.com/kivy-school/ksproject)-based
projects, written in Swift and compiled to WebAssembly.

This is a Swift/WASM rewrite of the Python/CarbonKivy
[ksproject-studio](https://github.com/kivy-school/ksproject-studio). It edits the
same project configuration (Android and iOS targets: package name, API levels,
SDK/NDK versions and paths, architectures, permissions, services, Info.plist and
entitlements) from the browser.

## Layout

| Path | Contents |
| --- | --- |
| `KSPStudioWasm/` | The Swift WebAssembly app (SwiftPM + Vite). |
| `ElementaryViews/` | Submodule: [Py-Swift/ElementaryViews](https://github.com/Py-Swift/ElementaryViews), the SwiftUI-inspired component library the UI is built on. |
| `research/` | Reference screenshots and a copy of the Kivy app being mirrored. |
| `src/ksp_studio/` | The Django server: serves the wasm app and the project API. |

## Getting started

`ElementaryViews` is a git submodule and `KSPStudioWasm/Package.swift` depends on
it by relative path, so clone recursively — a plain `git clone` will leave the
directory empty and the build will fail:

```sh
git clone --recursive https://github.com/kivy-school/ksp-studio.git
cd ksp-studio/KSPStudioWasm
```

Already cloned without `--recursive`:

```sh
git submodule update --init --recursive
```

### Requirements

- A Swift toolchain with the WebAssembly SDK installed (the app pins
  `swift-6.3.3-RELEASE_wasm`; see `KSPStudioWasm/.swift-version`)
- Node.js

### Build and run

```sh
npm install
npm run dev      # dev server, debug wasm build
npm run build    # production build into dist/
npm run preview  # serve the production build
```

## The server

The UI is a browser app with no filesystem access, so a small Django server
reads and writes the `pyproject.toml` for it. Run it from the root of the
ksproject you want to configure:

```sh
cd path/to/MyApp     # the directory holding pyproject.toml
ksp-studio           # http://127.0.0.1:8000
```

That directory *is* the target — there is no project picker and nothing to
configure. `--host` and `--port` are the only options.

### As a ksproject plugin

The same server is managed in the background through the ksproject CLI. Add
the module to `ksproject.toml` in the project root, alongside any other
plugins:

```toml
command_plugins = [
    "ksp_simple",
    "ksp_studio",
]
```

which adds a `studio` root command:

```sh
uv run ksproject studio start     # detaches and opens the UI in a browser
uv run ksproject studio stop
```

`start` waits until the server is actually accepting connections before it
opens the browser and returns, so the page never races an unbound port. Pass
`--no-open` to skip the browser; `--host` and `--port` work as they do on
`ksp-studio`. A port that's already taken is reported as such rather than
being mistaken for a successful start.

It writes `studio.pid` and `studio.log` into `.kivyschool/` — ksproject's
project-local state directory, already gitignored by `ksproject init`.
Starting twice reports the running pid rather than binding a second port, and
a pid file left over from a killed server is cleaned up instead of blocking
the next start.

Use `ksp-studio` directly when you want the server in the foreground; it is
the same process without the pid-file bookkeeping.

| Route | Purpose |
| --- | --- |
| `GET /api/project` | The project's path plus its parsed `pyproject.toml`. |
| `POST /api/project/save` | Writes an edited document back. |
| `GET /terminal` | A shell running in the project directory. |
| everything else | The built wasm app from `KSPStudioWasm/dist/`. |

`GET /api/project` returns one payload that both Swift models read: `pyProject`
holds the raw toml (`RootModel`, used by the Android tab) and the flat
top-level keys are the older `ProjectModel` shape (Python and Apple tabs).

This replaces the Vapor server the original psproject_configurator used. Vapor
served many projects out of one directory and routed `/project/:name`, which
the wasm app parsed back out of `location.pathname`; here the server is started
in the project it edits, so it just forwards that path to the app.

### Saving

**Save Configuration** lives in the nav bar, so it's there on every platform
and every tab. It used to sit at the foot of the Python and Apple tab panels,
which left the Android tab — the one built on the real `pyproject.toml` schema
— with no way to save at all.

A save writes *differences*, never a document. `pyproject.toml` is edited as a
parsed [tomlkit](https://github.com/python-poetry/tomlkit) document and dumped
back, so key order, blank lines, array layout, comments and the commented-out
keys `ksproject init` ships as documentation all survive — an untouched file
round-trips byte for byte. Editing one field changes one line. This is what
`uv add` manages and what rebuilding the file from a dict does not: that is
what flattened `authors` into `[[project.authors]]`, collapsed every
hand-formatted array onto one line, and dropped every comment in the file.

Writing only what changed matters as much as the writer. Both Swift models
fill in a default for every field they know about, so posting one back
wholesale invents settings the project never had — a whole `[tool.psproject]`
table of defaults for a project that has none. So the save carries a
`_baseline` alongside the models: a pristine copy of both, constructed from
the same response and never handed to a view. The server compares the two and
touches only the keys that differ. Because both sides come from the same
models, an untouched field is identical on both whether its value came from
the file or from a default, and produces nothing to write. Saving with nothing
edited reports "No changes to save" and doesn't open the file.

Removing a key removes it — including via a `null`, which is how the client's
optional fields (the Android tool paths) say "not set", since TOML has no
null. A successful save becomes the new baseline, so editing a field, saving,
then putting it back writes the revert out rather than seeing "no change"
against a stale copy.

A key that's *new* to the file goes next to the commented-out line documenting
it, if there is one. `ksproject init` ships the optional settings as examples —
`# sdk_path = "/path/to/android-sdk"` — and appending a newly enabled
`sdk_path` to the end of the table instead put it 30 lines below that, under
commented-out sub-table headers, where it looked like it belonged to some
other section. The comment itself is left in place; uncommenting would mean
deleting the example the template exists to show.

A save posted without a `_baseline` — an older wasm bundle against a newer
server — falls back to comparing against the file itself. That can't tell a
deletion from a section the client doesn't model, so it removes nothing, and
it refuses to create tables the document doesn't already have. It can still
edit anything it can see; it just can't inject a model's defaults.

### The terminal

The UI's "Open Terminal" button loads `/terminal` in an iframe, same as it did
under Vapor. Behind it is a PTY-backed login shell started in the project
directory, so colours, line editing, Ctrl-C and curses programs all behave —
`uv sync` and `ksproject android simple` are readable rather than a wall of
escape codes.

The front end is [xterm.js](https://xtermjs.org), so it is a real terminal
emulator — alternate screen buffer, scroll regions, cursor addressing, wide
characters. `less`, `vim` and `top` work.

Transport is HTTP polling, not a WebSocket: the server runs under `runserver`
(WSGI), and WebSockets would mean ASGI plus Channels or uvicorn to change how
the whole thing is launched. Over loopback the difference isn't perceptible.

xterm.js is served from the package at `/terminal/assets/…`, not from a CDN, so
an installed wheel works offline. `scripts/build_wasm.py` copies the three UMD
files out of `node_modules` into `src/ksp_studio/vendor/` (~290 KiB); they are
gitignored like the wasm bundle, and the terminal page reports what to run if
they're missing. Because they live in the package rather than in `web/`, the
terminal behaves the same whether the app is served from a wheel or from a
source checkout's `KSPStudioWasm/dist/`.

Two limits are deliberate:

- **It is refused to anyone not on this machine**, checked per request rather
  than at bind time. Serving the UI on `0.0.0.0` to reach it from another
  device is reasonable; handing out a shell with it is not.
- **The starting directory is confined to the project.** The `?path=` the UI
  passes back is honoured only if it resolves inside the project root.

Shells are tracked in-process and killed when the server stops, so none are
left behind.

### During development

`npm run dev` serves the app on vite's port and proxies `/api` to
`127.0.0.1:8000`, so run `ksp-studio` alongside it. Without it the UI still
loads, but there is no project to edit.

For `ksp-studio` to serve the app itself, build it first (`npm run build`).
It looks for the bundle in `$KSP_STUDIO_DIST`, then `src/ksp_studio/web/`,
then `KSPStudioWasm/dist/` — so a source checkout works straight after
`npm run build`.

### Packaging

```sh
uv build --wheel     # runs the wasm build itself, then packages it
```

`setup.py` hooks `build_py` to run `scripts/build_wasm.py --release` before
the package is collected, so the wheel always contains a freshly built,
wasm-opt'd bundle (~19 MB). That is the only reason `setup.py` exists — the
distribution metadata all lives in `pyproject.toml`, and the backend is
setuptools rather than `uv_build` because `uv_build` has no build hooks.

Building needs a Swift WebAssembly toolchain, npm and binaryen. Where those
aren't available, `KSP_STUDIO_SKIP_WASM_BUILD=1` packages whatever is already
staged instead of failing the build.

The script can also be run on its own (`python scripts/build_wasm.py`). It
copies `KSPStudioWasm/dist/` into `src/ksp_studio/web/`, which is inside the
Python package and therefore lands in the wheel — that is what makes an
installed `ksp-studio` serve a working UI instead of asking to be built. The
staged copy is a build artifact and is gitignored.

| Flag | Effect |
| --- | --- |
| `--release` (default) | `swift build -c release`, then `wasm-opt -Os --strip-debug`. |
| `--debug` | `swift build -c debug`, no wasm-opt. |
| `--skip-build` | Stage the existing `dist/` without rebuilding. |

Release is the only configuration worth shipping: 45.6 MiB against debug's
77.5 MiB, and ~19 MB once the wheel compresses it. Most of what remains is
Foundation, not dead code. A release build refuses to run if `wasm-opt` isn't
on `PATH` (`brew install binaryen`) rather than quietly producing an
unoptimized binary, which is what the vite plugin does on its own.
