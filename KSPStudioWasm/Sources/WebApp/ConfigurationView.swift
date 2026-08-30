import ElementaryUI
import ElementaryViews
import JavaScriptKit
import JavaScriptKitExtensions

// MARK: - Save Bar

/// Save button + status message. Lives in the nav bar rather than at the foot
/// of a tab: saving persists the whole project, so which tab happens to be
/// open has nothing to do with it, and Android — on `RootModel`, with no save
/// bar of its own — was unsaveable while each platform view owned one.
@View
struct SaveConfigurationBar {
    var model: ProjectModel
    var rootModel: RootModel
    @Binding var baseline: ProjectModel
    @Binding var baselineRoot: RootModel
    @Binding var saveMessage: String

    /// setTimeout handle for clearing the status message, so each save can
    /// cancel the previous one's timer instead of having it fire late and
    /// blank out a newer message.
    @State var clearTimer: Double = 0

    var body: some View {
        div(.class("flex items-center gap-3")) {
            if !saveMessage.isEmpty {
                span(.class("text-xs \(saveMessage.contains("Failed") ? "text-red-200" : "text-indigo-100")")) {
                    saveMessage
                }
            }

            button(.class("bg-white text-indigo-700 px-4 py-1.5 rounded hover:bg-indigo-50 font-medium text-sm cursor-pointer")) {
                "Save Configuration"
            }
            .onClick { _ in Task { await save() } }
        }
    }

    func save() async {
        do {
            let result = try await APIClient.saveProject(
                data: savePayload(
                    model: model,
                    rootModel: rootModel,
                    baseline: baseline,
                    baselineRoot: baselineRoot
                )
            )
            saveMessage = result.message
            // What's on disk is now what's in the models, so that becomes the
            // new baseline. Without this a field edited, saved, then put back
            // would match the stale baseline and produce no change — leaving
            // the file holding the value the user just undid.
            baseline = .construct(from: model.jsValue) ?? .init()
            baselineRoot = .construct(from: rootModel.jsValue) ?? .init()
        } catch {
            saveMessage = "Failed to save: \(error)"
        }

        // Clear the message after 3 seconds, cancelling any earlier timer.
        if clearTimer != 0 {
            _ = JSObject.global.clearTimeout!(clearTimer)
        }
        clearTimer = JSObject.global.setTimeout!(JSOneshotClosure { _ in
            saveMessage = ""
            return .undefined
        }, 3000).number ?? 0
    }
}

/// The body POSTed to `/api/project/save`.
///
/// Both models go up together — the legacy flat one the Python and Apple tabs
/// edit, and the real document the Android tab edits — under `_baseline`
/// alongside an untouched copy of each as they were loaded.
///
/// The baseline is what keeps a save from rewriting the file. Every model
/// fills in a default for every field it knows about, so posting one back
/// wholesale invents settings the project never had; the server compares the
/// two sides and writes only the keys that differ. Because both sides come
/// from the same models, an untouched field is byte-identical on both and
/// produces nothing to write — no matter whether its value came from the file
/// or from a default. See `ksp_studio/project.py`.
func savePayload(
    model: ProjectModel,
    rootModel: RootModel,
    baseline: ProjectModel,
    baselineRoot: RootModel
) -> JSValue {
    let body = saveSnapshot(model: model, rootModel: rootModel)
    body._baseline = saveSnapshot(model: baseline, rootModel: baselineRoot)
    return body.jsValue
}

/// Both models flattened into the one object shape the server reads.
func saveSnapshot(model: ProjectModel, rootModel: RootModel) -> JSObject {
    let obj = model.jsValue.object!
    obj.pyProject = rootModel.pyProject
    return obj
}

// MARK: - Python / uv platform view

@View
struct PythonConfigView {
    var model: ProjectModel
    @Binding var activeTab: ConfigTab

    var body: some View {
        div {
            div(.class("bg-white dark:bg-gray-800 rounded-lg shadow")) {
                ConfigTabBar(activeTab: $activeTab)

                div(.class("p-6 space-y-1 dark:text-gray-100")) {
                    switch activeTab {
                    case .project:
                        ProjectInfoTab(section: model.project)
                    case .deps:
                        DependenciesTab(
                            project: model.project,
                            deps: model.dependencyGroups
                        )
                    case .uv:
                        UVTab(section: model.uv)
                    case .buildsystem:
                        BuildSystemTab(section: model.buildSystem)
                    }
                }
            }
        }
    }
}

@View
struct ConfigTabBar {
    @Binding var activeTab: ConfigTab

    var body: some View {
        div(.class("flex")) {
            for tab in ConfigTab.allCases {
                ConfigTabButton(tab: tab, isActive: activeTab == tab, onSelect: { activeTab = tab })
            }
        }
        .border(.separator, edges: .bottom)
    }
}

@View
struct ConfigTabButton {
    var tab: ConfigTab
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        button(.class("px-4 py-3 text-sm font-medium border-b-2 transition-colors cursor-pointer \(isActive ? "border-indigo-600 text-indigo-600" : "border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200")")) {
            span { tab.icon }
            span(.class("ml-1")) { tab.displayLabel }
        }
        .onClick { _ in onSelect() }
    }
}

// MARK: - Project Info (Python)

@View
struct ProjectInfoTab {
    var section: ProjectSection

    var body: some View {
        SectionHeader(title: "Project Info", icon: "📋")
        FormField(fieldLabel: "Name", value: #Binding(section.name))
        FormField(fieldLabel: "Version", value: #Binding(section.version))
        FormField(fieldLabel: "Description", value: #Binding(section.description))
        FormField(fieldLabel: "Readme", value: #Binding(section.readme))
        FormField(fieldLabel: "Requires Python", value: #Binding(section.requiresPython))
        FormField(fieldLabel: "Authors", value: #Binding(section.authors))

        SectionHeader(title: "Scripts", icon: "📜")
        KeyValueEditor(dict: #Binding(section.scripts))
    }
}

// MARK: - Dependencies (Python)

@View
struct DependenciesTab {
    var project: ProjectSection
    var deps: DependencyGroupsSection

    var body: some View {
        SectionHeader(title: "Dependency Management", icon: "📦")
        ListEditor(fieldLabel: "Dependencies", items: #Binding(project.dependencies))

        SectionHeader(title: "Dependency Groups", icon: "📚")
        ListEditor(fieldLabel: "Dev Dependencies", items: #Binding(deps.dev))
        ListEditor(fieldLabel: "iphoneos Dependencies", items: #Binding(deps.iphoneos))
    }
}

// MARK: - UV (Python)

@View
struct UVTab {
    var section: UVSection

    var body: some View {
        SectionHeader(title: "UV Settings", icon: "⚡")
        SelectField(fieldLabel: "Index Strategy", selection: #Binding(section.indexStrategy))
        FormField(fieldLabel: "Index URL", value: #Binding(section.indexURL))
        BoolField(fieldLabel: "Index Enabled", value: #Binding(section.indexEnabled))

        SectionHeader(title: "Sources", icon: "📡")
        KeyValueEditor(dict: #Binding(section.sources))

        SectionHeader(title: "Extra Index URLs", icon: "🔗")
        ListEditor(fieldLabel: "Extra Index URLs", items: #Binding(section.extraIndexURL))

        SectionHeader(title: "Workspace Members", icon: "📂")
        ListEditor(fieldLabel: "Members", items: #Binding(section.workspaceMembers))
    }
}

// MARK: - Build System (Python)

@View
struct BuildSystemTab {
    var section: BuildSystemSection

    var body: some View {
        SectionHeader(title: "Build System Settings", icon: "🔧")
        FormField(fieldLabel: "Build Backend", value: #Binding(section.buildBackend))
        ListEditor(fieldLabel: "Build Requires", items: #Binding(section.requires))
    }
}

// MARK: - Apple/iOS platform view

/// Top-level view for the Apple platform: Home / Permissions / Miscellaneous,
/// matching kivy's `ios.kv` `CTabHeader` exactly (no "PSProject" wrapper tab).
@View
struct AppleConfigView {
    var model: ProjectModel
    @Binding var activeTab: AppleTab
    @Binding var activeHomeSubTab: AppleHomeSubTab

    var body: some View {
        div {
            div(.class("bg-white dark:bg-gray-800 rounded-lg shadow")) {
                AppleTabBar(activeTab: $activeTab)

                div(.class("p-6 space-y-1 dark:text-gray-100")) {
                    switch activeTab {
                    case .home:
                        AppleHomeTab(section: model.psproject, activeSubTab: $activeHomeSubTab)
                    case .permissions:
                        ApplePermissionsTab(section: model.psproject)
                    case .miscellaneous:
                        IOSMiscellaneousTab(section: model.psproject)
                    }
                }
            }
        }
    }
}

@View
struct AppleTabBar {
    @Binding var activeTab: AppleTab

    var body: some View {
        div(.class("flex")) {
            for tab in AppleTab.allCases {
                AppleTabButton(tab: tab, isActive: activeTab == tab, onSelect: { activeTab = tab })
            }
        }
        .border(.separator, edges: .bottom)
    }
}

@View
struct AppleTabButton {
    var tab: AppleTab
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        button(.class("px-4 py-3 text-sm font-medium border-b-2 transition-colors cursor-pointer \(isActive ? "border-indigo-600 text-indigo-600" : "border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200")")) {
            span { tab.icon }
            span(.class("ml-1")) { tab.displayLabel }
        }
        .onClick { _ in onSelect() }
    }
}

// MARK: - Apple: Home

/// Kivy's `IHome` is just a bundle-id field; this app's `[tool.psproject]`
/// model has more than that, so those extra concerns (backends, Info.plist,
/// entitlements, swift packages) live as sub-tabs here.
@View
struct AppleHomeTab {
    var section: PSProjectSection
    @Binding var activeSubTab: AppleHomeSubTab

    var body: some View {
        div(.class("rounded-lg")) {
            div(.class("flex")) {
                for tab in AppleHomeSubTab.allCases {
                    AppleHomeSubTabButton(tab: tab, isActive: activeSubTab == tab, onSelect: { activeSubTab = tab })
                }
            }
            .border(.separator, edges: .bottom)

            div(.class("p-4")) {
                switch activeSubTab {
                case .info:
                    div(.class("grid grid-cols-1 md:grid-cols-2 gap-4 mb-4")) {
                        CardTextField(
                            fieldLabel: "App Name",
                            value: #Binding(section.appName),
                            helperText: "e.g. com.kivyschool.yourapp",
                            placeholder: "org.example.myapp"
                        )
                    }
                    BoolField(fieldLabel: "Copy __main__.py", value: #Binding(section.copyMainPy))
                    BoolField(fieldLabel: "Cythonized", value: #Binding(section.cythonized))
                    BoolField(fieldLabel: "Pip Install App", value: #Binding(section.pipInstallApp))
                case .psbackends:
                    ListEditor(fieldLabel: "Backends", items: #Binding(section.backends))
                    ListEditor(fieldLabel: "iOS Backends", items: #Binding(section.iosBackends))
                case .infoPlist:
                    InfoPlistEditor(data: section.infoPlist)
                case .entitlements:
                    EntitlementsEditor(data: section.entitlements)
                case .swiftPackages:
                    KeyValueEditor(dict: #Binding(section.swiftPackages))
                }
            }
        }
        .border(.separator)
    }
}

@View
struct AppleHomeSubTabButton {
    var tab: AppleHomeSubTab
    var isActive: Bool
    var onSelect: () -> Void

    var body: some View {
        button(.class("px-3 py-2 text-xs font-medium border-b-2 transition-colors cursor-pointer \(isActive ? "border-indigo-500 text-indigo-600" : "border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200")")) {
            tab.displayLabel
        }
        .onClick { _ in onSelect() }
    }
}

// MARK: - Apple: Permissions

/// Kivy's `IPermissions` fetches known permission names from an API for a
/// picker (`IPermissionsModal`); no such API is wired up here, so this is a
/// plain add/remove list backed by `PSProjectSection.iosPermissions`.
@View
struct ApplePermissionsTab {
    var section: PSProjectSection

    var body: some View {
        SectionHeader(title: "iOS Permissions", icon: "🛡️")
        ListEditor(fieldLabel: "Permissions", items: #Binding(section.iosPermissions))
    }
}
