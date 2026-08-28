// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "KSProjectStudioWasm",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/elementary-swift/elementary-ui.git", "0.4.0"..<"0.5.0"),
        .package(url: "https://github.com/elementary-swift/elementary", "0.7.0"..<"0.8.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.55.0"),
        .package(url: "https://github.com/Py-Swift/JavaScriptKitExtensions", branch: "master"),
        .package(path: "../ElementaryViews"),
    ],
    targets: [
        .executableTarget(
            name: "WebApp",
            dependencies: [
                .product(name: "ElementaryUI", package: "elementary-ui"),
                .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "JavaScriptKitExtensions", package: "JavaScriptKitExtensions"),
                "ElementaryViews",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ],
            linkerSettings: [
                // Default wasm-ld initial memory (~37MiB) is tight enough
                // that a moderately complex view tree can run the allocator
                // out of headroom mid-render (`memory.grow` past the default
                // ~37MiB ceiling doesn't reliably succeed in this runtime,
                // and the failure isn't checked, so it surfaces as "memory
                // access out of bounds" rather than a clean OOM). Bumped
                // both initial and max well past what any current screen
                // needs. These flags only apply when linking this target
                // (WebApp, the wasm executable) — passing them package-wide
                // instead (e.g. via extraBuildArgs in vite.config.ts) also
                // reaches the host-side macro-plugin tools built with
                // Apple's `ld`, which doesn't understand wasm-ld-only flags
                // and fails to link.
                //
                // Separately from the *heap* sizing above, the wasm shadow
                // stack needs its own headroom. It defaults to ~1.4MiB and,
                // in the default (non-`--stack-first`) layout, grows *down*
                // directly into the static data segment — so overflowing it
                // doesn't trap, it silently overwrites type metadata and
                // nominal type descriptors. The damage only surfaces later,
                // when the runtime next resolves a type by mangled name, as
                // whichever trap the corrupted bytes happen to produce
                // ("table index is out of bounds" in `swift_getTypeByMangledName`,
                // "memory access out of bounds" in `strlen` under
                // `ParsedTypeIdentity::parse`, and so on) — which is why this
                // read as a random assortment of reconciler/binding bugs
                // rather than as stack exhaustion.
                //
                // `_makeNode` recursion is proportional to view-tree *depth*,
                // and debug frames are several times larger than release
                // ones, so debug builds (`npm run dev`) blow the default
                // stack on trees that release builds render fine — matching
                // the "only crashes in dev" and "one component too many"
                // symptoms. `--stack-first` moves the stack below the data
                // segment so any future overflow faults immediately instead
                // of corrupting memory silently.
                .unsafeFlags([
                    "-Xlinker", "--max-memory=1073741824",
                    "-Xlinker", "--initial-memory=536870912",
                    "-Xlinker", "-z", "-Xlinker", "stack-size=67108864",
                    "-Xlinker", "--stack-first",
                    // `--stack-first` puts the stack at the bottom of linear
                    // memory, so the data segment has to start above it —
                    // wasm-ld rejects a `--global-base` below the stack size.
                    // Keep these two in sync when changing the stack size.
                    "-Xlinker", "--global-base=67108864",
                ]),
            ]
        ),
    ]
)
