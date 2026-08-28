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
| `src/` | Python package scaffolding. |

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

The dev server proxies `/api` to a Vapor backend on `127.0.0.1:8000`; without it
running, the UI still loads and project configuration is session-only.
