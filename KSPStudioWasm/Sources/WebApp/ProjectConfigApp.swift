import ElementaryUI
import JavaScriptKit

// ── Tab definitions matching the server-side layout ──

enum MainPage: String, CaseIterable {
    case config = "config"
    case utils = "utils"

    var displayLabel: String {
        switch self {
        case .config: "Project Configuration"
        case .utils: "Utils"
        }
    }
    var icon: String {
        switch self {
        case .config: "⚙️"
        case .utils: "🔧"
        }
    }
}

/// Tabs for the Python/uv platform — general packaging concerns (pyproject.toml
/// `[project]`, `[dependency-groups]`, `[tool.uv]`, `[build-system]`), not
/// Apple-specific. Previously these lived alongside a "PSProject" tab in one
/// shared tab bar regardless of which platform was selected in the sidebar;
/// split out so each platform only shows what's actually relevant to it.
enum ConfigTab: String, CaseIterable {
    case project = "project"
    case deps = "deps"
    case uv = "uv"
    case buildsystem = "buildsystem"

    var displayLabel: String {
        switch self {
        case .project: "Project"
        case .deps: "Dependencies"
        case .uv: "UV"
        case .buildsystem: "Build System"
        }
    }
    var icon: String {
        switch self {
        case .project: "📦"
        case .deps: "📚"
        case .uv: "⚡"
        case .buildsystem: "🔧"
        }
    }
}

/// Top-level tabs for the Apple/iOS platform, matching kivy's `ios.kv`
/// (`CTabHeaderItem`s: Home, Permissions, Miscellaneous) exactly — no
/// intermediate "PSProject" wrapper tab.
enum AppleTab: String, CaseIterable {
    case home = "home"
    case permissions = "permissions"
    case miscellaneous = "miscellaneous"

    var displayLabel: String {
        switch self {
        case .home: "Home"
        case .permissions: "Permissions"
        case .miscellaneous: "Miscellaneous"
        }
    }
    var icon: String {
        switch self {
        case .home: "🏠"
        case .permissions: "🛡️"
        case .miscellaneous: "🖼️"
        }
    }
}

/// Top-level tabs for the Android platform, matching kivy's `android.kv`
/// `CTabHeader` exactly (Home / Permissions / Services / Miscellaneous).
enum AndroidTab: String, CaseIterable {
    case home = "home"
    case permissions = "permissions"
    case services = "services"
    case miscellaneous = "miscellaneous"

    var displayLabel: String {
        switch self {
        case .home: "Home"
        case .permissions: "Permissions"
        case .services: "Services"
        case .miscellaneous: "Miscellaneous"
        }
    }
    var icon: String {
        switch self {
        case .home: "🏠"
        case .permissions: "🛡️"
        case .services: "⚙️"
        case .miscellaneous: "🖼️"
        }
    }
}

enum Platform: String, CaseIterable {
    case python = "python"
    case android = "android"
    case apple = "apple"

    var displayLabel: String {
        switch self {
        case .python: "Python / uv"
        case .android: "Android"
        case .apple: "Apple (iOS)"
        }
    }
    /// Served from `public/icons/` (copied from the original ksproject-studio assets).
    var iconPath: String {
        switch self {
        case .python: "/icons/python64.png"
        case .android: "/icons/android64.png"
        case .apple: "/icons/apple64.png"
        }
    }
}

/// Inner tabs under Apple's "Home" tab. Kivy's `IHome` only has a single
/// bundle-id field; this app's `[tool.psproject]` model carries more than
/// that (backends, Info.plist, entitlements, swift packages), so those live
/// as sub-tabs of Home rather than as more top-level tabs kivy doesn't have.
enum AppleHomeSubTab: String, CaseIterable {
    case info = "info"
    case psbackends = "psbackends"
    case infoPlist = "info_plist"
    case entitlements = "entitlements"
    case swiftPackages = "swift_packages"

    var displayLabel: String {
        switch self {
        case .info: "Info"
        case .psbackends: "Backends"
        case .infoPlist: "Info.plist"
        case .entitlements: "Entitlements"
        case .swiftPackages: "Swift Packages"
        }
    }
}

/// Root view for the project configuration page.
@View
struct ProjectConfigApp {
    var folderName: String

    @State var model: ProjectModel = ProjectModel()
    /// Separate from `model` on purpose — built on the real `PyProjectToml`
    /// schema (see `RootModel.swift`), not the legacy flat bridge. Only the
    /// Android tab reads from this for now.
    @State var rootModel: RootModel = RootModel()
    @State var activePlatform: Platform = .apple
    @State var activePage: MainPage = .config
    @State var activeConfigTab: ConfigTab = .project
    @State var activeAppleTab: AppleTab = .home
    @State var activeAppleHomeSubTab: AppleHomeSubTab = .info
    @State var activeAndroidTab: AndroidTab = .home
    @State var saveMessage: String = ""
    @State var isLoading: Bool = true
    @State var showTerminal: Bool = false
    @State var colorScheme: AppColorScheme = documentIsDark() ? .dark : .light

    var body: some View {
        div {
            // Nav bar
            NavBar(colorScheme: $colorScheme)

            div(.class("flex flex-1 min-h-0")) {
                PlatformSidebar(activePlatform: $activePlatform, onSelect: selectPlatform)

                div(.class("flex-1 overflow-y-auto")) {
                    main(.class("max-w-screen-2xl mx-auto py-8 px-6")) {
                        if isLoading {
                            div(.class("text-center py-20 text-gray-500 dark:text-gray-400")) {
                                p { "Loading project..." }
                            }
                        } else {
                            ProjectHeader(
                                model: model,
                                folderName: folderName,
                                onReload: loadProject
                            )

                            div(.class("flex gap-6")) {
                                div(.class("flex-1 min-w-0")) {
                                    MainPageTabBar(activePage: $activePage)

                                    if activePage == .config {
                                        switch activePlatform {
                                        case .android:
                                            AndroidConfigView(
                                                section: rootModel.android,
                                                activeTab: $activeAndroidTab
                                            )
                                        case .python:
                                            PythonConfigView(
                                                model: model,
                                                activeTab: $activeConfigTab,
                                                folderName: folderName,
                                                saveMessage: $saveMessage
                                            )
                                        case .apple:
                                            AppleConfigView(
                                                model: model,
                                                activeTab: $activeAppleTab,
                                                activeHomeSubTab: $activeAppleHomeSubTab,
                                                folderName: folderName,
                                                saveMessage: $saveMessage
                                            )
                                        }
                                    } else {
                                        UtilsView()
                                    }
                                }

                                SidebarView(projectPath: model.path, showTerminal: $showTerminal)
                            }
                        }
                    }
                }
            }

            // Terminal modal overlay
            if showTerminal {
                TerminalModal(projectPath: model.path, showTerminal: $showTerminal)
            }
        }
        .attributes(.class("bg-gray-50 dark:bg-gray-900 min-h-screen flex flex-col"))
        .environment(#Key(\.colorScheme), colorScheme)
        .task {
            await loadProject()
        }
    }

    /// Resets every platform's sub-tab back to its default (Home) on every
    /// platform switch. Not just tidiness: leaving a platform on its
    /// Miscellaneous tab, switching platforms, then switching back
    /// reproducibly crashes the wasm runtime (confirmed: mounting the exact
    /// same tab twice *within* one platform is fine every time; it's
    /// specifically going through the outer `switch activePlatform` — full
    /// unmount of one concrete view tree, mount of another, then back — that
    /// doesn't survive. This sidesteps it by never auto-remounting a
    /// Miscellaneous tab that way; you can still open it again with an
    /// explicit click once you're back on that platform.
    func selectPlatform(_ platform: Platform) {
        activePlatform = platform
        activeConfigTab = .project
        activeAppleTab = .home
        activeAndroidTab = .home
    }

    func loadProject() async {
        isLoading = true
        do {
            let jsObj = try await APIClient.fetchProject(folderName: folderName)
            model = .construct(from: jsObj.jsValue) ?? .init()
        } catch {
            print("Failed to load project: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Nav Bar

@View
struct NavBar {
    @Binding var colorScheme: AppColorScheme

    var body: some View {
        nav(.class("bg-indigo-600 text-white shadow-lg")) {
            div(.class("max-w-screen-2xl mx-auto px-6 py-3 flex items-center justify-between")) {
                a(.href("/"), .class("text-xl font-bold tracking-tight")) { "KSProject Studio" }
                div(.class("flex items-center gap-4 text-sm")) {
                    //a(.href("/"), .class("hover:text-indigo-200")) { "Dashboard" }
                    //a(.href("/new"), .class("hover:text-indigo-200")) { "New Project" }
                    button(.class("text-lg leading-none cursor-pointer hover:text-indigo-200")) {
                        colorScheme == .dark ? "🌙" : "☀️"
                    }
                    .onClick { _ in
                        colorScheme = colorScheme == .dark ? .light : .dark
                        setDocumentIsDark(colorScheme == .dark)
                    }
                }
            }
        }
    }
}

/// Reads the `dark` class already applied to `<html>` by the inline script in index.html.
func documentIsDark() -> Bool {
    JSObject.global.document.documentElement.classList.contains("dark").boolean ?? false
}

/// Toggles the `dark` class on `<html>` and persists the choice.
func setDocumentIsDark(_ isDark: Bool) {
    _ = JSObject.global.document.documentElement.classList.toggle("dark", isDark)
    _ = JSObject.global.localStorage.setItem("colorScheme", isDark ? "dark" : "light")
}

// MARK: - Project Header

@View
struct ProjectHeader {
    var model: ProjectModel
    var folderName: String
    var onReload: () async -> Void

    var body: some View {
        div(.class("flex items-center gap-2 mb-6")) {
            a(.href("/"), .class("text-indigo-600 hover:text-indigo-800 text-sm")) { "← Back" }
            h1(.class("text-2xl font-bold text-gray-800 dark:text-gray-100")) { model.project.name }
            span(.class("text-sm text-gray-400 ml-2")) { model.path }
            button(.class("ml-auto flex items-center gap-1 text-gray-800 dark:text-gray-200 hover:text-indigo-600 transition-colors text-sm cursor-pointer")) {
                span { "↻" }
                span { "Reload" }
            }
            .onClick { _ in
                Task { await onReload() }
            }
        }
    }
}

// MARK: - Main Page Tab Bar

@View
struct MainPageTabBar {
    @Binding var activePage: MainPage

    var body: some View {
        div(.class("flex border-b border-gray-200 dark:border-gray-700 mb-4")) {
            for page in MainPage.allCases {
                MainPageTabButton(page: page, isActive: activePage == page, onSelect: { activePage = page })
            }
        }
    }
}

@View
struct MainPageTabButton {
    var page: MainPage
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        button(.class("px-4 py-2 text-sm font-medium border-b-2 transition-colors cursor-pointer \(isActive ? "border-indigo-600 text-indigo-600" : "border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200")")) {
            span { page.icon }
            span(.class("ml-1")) { page.displayLabel }
        }
        .onClick { _ in onSelect() }
    }
}

// MARK: - Platform Sidebar

/// Left-hand icon rail that switches between platform sections (Python/uv,
/// Android, Apple). Always dark, independent of the light/dark toggle —
/// same idea as an editor's activity bar.
@View
struct PlatformSidebar {
    @Binding var activePlatform: Platform
    var onSelect: (Platform) -> Void

    var body: some View {
        div(.class("w-16 flex-shrink-0 bg-gray-900 flex flex-col items-center gap-1 py-4")) {
            for platform in Platform.allCases {
                PlatformSidebarButton(
                    platform: platform,
                    isActive: activePlatform == platform,
                    onSelect: { onSelect(platform) }
                )
            }
        }
    }
}

@View
struct PlatformSidebarButton {
    var platform: Platform
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        button(
            .class("relative w-full flex items-center justify-center py-3 cursor-pointer transition-opacity \(isActive ? "opacity-100" : "opacity-50 hover:opacity-80")"),
            .custom(name: "title", value: platform.displayLabel)
        ) {
            if isActive {
                span(.class("absolute left-0 top-2 bottom-2 w-0.5 bg-indigo-500 rounded-full")) { "" }
            }
            img(
                .src(platform.iconPath),
                .alt(platform.displayLabel),
                .class("w-7 h-7 object-contain")
            )
        }
        .onClick { _ in onSelect() }
    }
}

// MARK: - Utils View (placeholder)

@View
struct UtilsView {
    var body: some View {
        div(.class("bg-white dark:bg-gray-800 rounded-lg shadow p-6 space-y-4")) {
            h3(.class("text-lg font-semibold text-gray-800 dark:text-gray-100")) { "🔧 Utility Settings" }
            p(.class("text-gray-500 dark:text-gray-400 text-sm")) { "Coming soon..." }
        }
    }
}

// MARK: - Android Placeholder View

/// Stand-in for the Android platform section. The reference app (kivy's
/// ksproject-studio) has real Home/Permissions/Services/Miscellaneous screens
/// here — this project doesn't have an Android section in `ProjectModel` or
/// the backend API yet, so this is a placeholder until that model exists.
@View
struct AndroidPlaceholderView {
    var body: some View {
        div(.class("bg-white dark:bg-gray-800 rounded-lg shadow")) {
            div(.class("flex border-b border-gray-200 dark:border-gray-700 px-2")) {
                for label in ["Home", "Permissions", "Services", "Miscellaneous"] {
                    span(.class("px-4 py-2 text-sm font-medium text-gray-400 dark:text-gray-500")) { label }
                }
            }
            div(.class("p-6 text-center text-gray-500 dark:text-gray-400 text-sm")) {
                p { "🤖 Android configuration isn't wired up yet." }
                p(.class("mt-1 text-xs text-gray-400 dark:text-gray-500")) {
                    "Package name, API levels, NDK/SDK paths, permissions and services are coming soon."
                }
            }
        }
    }
}

// MARK: - Sidebar

@View
struct SidebarView {
    var projectPath: String
    @Binding var showTerminal: Bool


    var body: some View {
        div(.class("w-56 flex-shrink-0")) {
            div(.class("bg-white dark:bg-gray-800 rounded-lg shadow p-4 space-y-3 sticky top-8")) {
                h3(.class("text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider")) { "Tools" }

                // a(.href("vscode://file\(projectPath)"), .class("flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors")) {
                //     span { "📂" }
                //     span { "Open in VSCode" }
                // }

                button(.class("flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors w-full text-left cursor-pointer")) {
                    span { "💻" }
                    span { "Open Terminal" }
                }
                .onClick { _ in
                    showTerminal = true
                }
                // button(.class("flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300 hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors w-full text-left cursor-pointer")) {
                //     span { "🎹" }
                //     span { "Open Sequencer" }
                // }
//                .onClick { _ in
//                    SequencerPopupManager.shared.open()
//                }
            }
        }
    }
}

// MARK: - Terminal Modal

@View
struct TerminalModal {
    var projectPath: String
    @Binding var showTerminal: Bool

    var terminalURL: String {
        "/terminal?path=\(projectPath)"
    }

    var body: some View {
        div(.class("fixed inset-0 z-50")) {
            // Backdrop
            div(.class("absolute inset-0 bg-black/50")) { "" }
                .onClick { _ in showTerminal = false }

            // Modal content
            div(.class("absolute inset-8 bg-gray-900 rounded-lg shadow-2xl flex flex-col overflow-hidden")) {
                // Header
                div(.class("flex items-center justify-between px-4 py-2 bg-gray-800 text-white")) {
                    span(.class("text-sm font-medium")) { "Terminal" }
                    button(
                        .type(.button),
                        .class("text-gray-400 hover:text-white text-lg leading-none cursor-pointer")
                    ) { "✕" }
                    .onClick { _ in showTerminal = false }
                }

                // Terminal iframe
                div(.class("flex-1")) {
                    iframe(
                        .src(terminalURL),
                        .class("w-full h-full border-0")
                    ) { "" }
                }
            }
        }
        .onKeyDown { event in
            if event.key == "Escape" {
                showTerminal = false
            }
        }
    }
}
