import ElementaryUI
import ElementaryViews
import JavaScriptKit
import JavaScriptKitExtensions

// MARK: - Save Bar

/// Save button + status message, shared by `PythonConfigView` and
/// `AppleConfigView` (each platform gets its own tab bar, but saving always
/// persists the whole `ProjectModel`).
@View
struct SaveConfigurationBar {
    var folderName: String
    var model: ProjectModel
    @Binding var saveMessage: String

    var body: some View {
        div(.class("p-6 bg-gray-50 dark:bg-gray-900 dark:border-gray-700 rounded-b-lg flex items-center gap-4 border-t")) {
            button(.class("bg-indigo-600 text-white px-6 py-2 rounded hover:bg-indigo-700 font-medium cursor-pointer")) {
                "Save Configuration"
            }
            .onClick { _ in Task { await save() } }

            if !saveMessage.isEmpty {
                span(.class("text-sm \(saveMessage.contains("Failed") ? "text-red-600" : "text-green-600")")) {
                    saveMessage
                }
            }
        }
    }

    func save() async {
        do {
            let result = try await APIClient.saveProject(folderName: folderName, data: model.jsValue)
            saveMessage = result.message
        } catch {
            saveMessage = "Failed to save: \(error)"
        }
        // Clear message after 3 seconds
        _ = JSObject.global.setTimeout!(JSOneshotClosure { _ in
            saveMessage = ""
            return .undefined
        }, 3000)
    }
}

// MARK: - Python / uv platform view

@View
struct PythonConfigView {
    var model: ProjectModel
    @Binding var activeTab: ConfigTab
    var folderName: String
    @Binding var saveMessage: String

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

                SaveConfigurationBar(folderName: folderName, model: model, saveMessage: $saveMessage)
            }
        }
    }
}

@View
struct ConfigTabBar {
    @Binding var activeTab: ConfigTab

    var body: some View {
        div(.class("flex border-b border-gray-200 dark:border-gray-700")) {
            for tab in ConfigTab.allCases {
                ConfigTabButton(tab: tab, isActive: activeTab == tab, onSelect: { activeTab = tab })
            }
        }
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
    var folderName: String
    @Binding var saveMessage: String

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

                SaveConfigurationBar(folderName: folderName, model: model, saveMessage: $saveMessage)
            }
        }
    }
}

@View
struct AppleTabBar {
    @Binding var activeTab: AppleTab

    var body: some View {
        div(.class("flex border-b border-gray-200 dark:border-gray-700")) {
            for tab in AppleTab.allCases {
                AppleTabButton(tab: tab, isActive: activeTab == tab, onSelect: { activeTab = tab })
            }
        }
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
        div(.class("border border-gray-200 dark:border-gray-700 rounded-lg")) {
            div(.class("flex border-b border-gray-200 dark:border-gray-700")) {
                for tab in AppleHomeSubTab.allCases {
                    AppleHomeSubTabButton(tab: tab, isActive: activeSubTab == tab, onSelect: { activeSubTab = tab })
                }
            }

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
