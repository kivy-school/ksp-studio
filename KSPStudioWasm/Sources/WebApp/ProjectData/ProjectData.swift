import Reactivity
import JavaScriptKit
import JavaScriptKitExtensions

// MARK: - Top-level model

/// Root reactive model holding all TOML sections.
/// Each section is a separate @Reactive class for fine-grained tracking.
@Reactive
final class ProjectModel: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {

    var path: String
    var unmanaged: String
    var unmanagedKeys: [String: String]

    // Tracked (not @ReactiveIgnored): sections are swapped wholesale on
    // load/reset, and that reassignment needs to trigger a refresh.
    var project: ProjectSection
    var buildSystem: BuildSystemSection
    var dependencyGroups: DependencyGroupsSection
    var uv: UVSection
    var psproject: PSProjectSection

    @ReactiveIgnored
    var folderName: String {
        guard let lastSlash = path.lastIndex(of: "/") else { return path }
        return String(path[path.index(after: lastSlash)...])
    }
    
    init(
        path: String? = nil,
        unmanaged: String? = nil,
        unmanagedKeys: [String : String]? = nil,
        project: ProjectSection? = nil,
        buildSystem: BuildSystemSection? = nil,
        dependencyGroups: DependencyGroupsSection? = nil,
        uv: UVSection? = nil,
        psproject: PSProjectSection? = nil
    ) {
        self.path = path ?? ""
        self.unmanaged = unmanaged ?? ""
        self.unmanagedKeys = unmanagedKeys ?? [:]
        self.project = project ?? .init()
        self.buildSystem = buildSystem ?? .init()
        self.dependencyGroups = dependencyGroups ?? .init()
        self.uv = uv ?? .init()
        self.psproject = psproject ?? .init()
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.path = path
        obj._unmanaged = unmanaged
        obj._unmanaged_keys = unmanagedKeys
        obj.project = project
        obj["build-system"] = buildSystem
        obj["dependency-groups"] = dependencyGroups
        obj["tool.uv"] = uv
        obj["tool.psproject"] = psproject
        return obj.jsValue
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(
            path: obj.path,
            unmanaged: obj._unmanaged,
            unmanagedKeys: obj._unmanaged_keys,
            project: obj.project,
            buildSystem: obj["build-system"],
            dependencyGroups: obj["dependency-groups"],
            uv: obj["tool.uv"],
            psproject: obj["tool.psproject"]
        )
    }

    enum CodingKeys: String, CodingKey {
        case path
        case unmanaged = "_unmanaged"
        case unmanagedKeys = "_unmanaged_keys"
        case project
        case buildSystem = "build-system"
        case dependencyGroups = "dependency-groups"
        case uv = "tool.uv"
        case psproject = "tool.psproject"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.path = try c.decodeIfPresent(String.self, forKey: .path) ?? ""
        self.unmanaged = try c.decodeIfPresent(String.self, forKey: .unmanaged) ?? ""
        self.unmanagedKeys = try c.decodeIfPresent([String: String].self, forKey: .unmanagedKeys) ?? [:]
        self.project = try c.decodeIfPresent(ProjectSection.self, forKey: .project) ?? .init()
        self.buildSystem = try c.decodeIfPresent(BuildSystemSection.self, forKey: .buildSystem) ?? .init()
        self.dependencyGroups = try c.decodeIfPresent(DependencyGroupsSection.self, forKey: .dependencyGroups) ?? .init()
        self.uv = try c.decodeIfPresent(UVSection.self, forKey: .uv) ?? .init()
        self.psproject = try c.decodeIfPresent(PSProjectSection.self, forKey: .psproject) ?? .init()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(path, forKey: .path)
        try c.encode(unmanaged, forKey: .unmanaged)
        try c.encode(unmanagedKeys, forKey: .unmanagedKeys)
        try c.encode(project, forKey: .project)
        try c.encode(buildSystem, forKey: .buildSystem)
        try c.encode(dependencyGroups, forKey: .dependencyGroups)
        try c.encode(uv, forKey: .uv)
        try c.encode(psproject, forKey: .psproject)
    }
}

// MARK: - [project]

@Reactive
final class ProjectSection: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    
    var name: String
    var version: String
    var description: String
    var readme: String
    var requiresPython: String
    var authors: String
    var dependencies: [String]
    var scripts: [String: String]
    
    init(name: String? = nil, version: String? = nil, description: String? = nil, readme: String? = nil, requiresPython: String? = nil, authors: String? = nil, dependencies: [String]? = nil, scripts: [String : String]? = nil) {
        self.name = name ?? ""
        self.version = version ?? "0.1.0"
        self.description = description ?? ""
        self.readme = readme ?? "README.md"
        self.requiresPython = requiresPython ?? ">=3.13"
        self.authors = authors ?? ""
        self.dependencies = dependencies ?? []
        self.scripts = scripts ?? [:]
    }
    
    var jsValue: JSValue {
        let obj = JSObject()
        obj.name = name
        obj.version = version
        obj["description"] = description
        obj.readme = readme
        obj["requires-python"] = requiresPython
        obj.authors = authors
        obj.dependencies = dependencies
        obj.scripts = scripts
        return obj.jsValue
    }
    
    static func construct(from value: JSValue) -> Self? {
        guard let js = value.object else { return nil }
        return Self.init(
            name: js.name,
            version: js.version,
            description: js["description"],
            readme: js.readme,
            requiresPython: js["requires-python"],
            authors: js.authors,
            dependencies: js.dependencies,
            scripts: js.scripts
        )
    }

    enum CodingKeys: String, CodingKey {
        case name, version, description, readme
        case requiresPython = "requires-python"
        case authors, dependencies, scripts
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.version = try c.decodeIfPresent(String.self, forKey: .version) ?? "0.1.0"
        self.description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.readme = try c.decodeIfPresent(String.self, forKey: .readme) ?? "README.md"
        self.requiresPython = try c.decodeIfPresent(String.self, forKey: .requiresPython) ?? ">=3.13"
        self.authors = try c.decodeIfPresent(String.self, forKey: .authors) ?? ""
        self.dependencies = try c.decodeIfPresent([String].self, forKey: .dependencies) ?? []
        self.scripts = try c.decodeIfPresent([String: String].self, forKey: .scripts) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(version, forKey: .version)
        try c.encode(description, forKey: .description)
        try c.encode(readme, forKey: .readme)
        try c.encode(requiresPython, forKey: .requiresPython)
        try c.encode(authors, forKey: .authors)
        try c.encode(dependencies, forKey: .dependencies)
        try c.encode(scripts, forKey: .scripts)
    }
}

// MARK: - [build-system]

@Reactive
final class BuildSystemSection: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var buildBackend: String
    var requires: [String]

    init(buildBackend: String? = nil, requires: [String]? = nil) {
        self.buildBackend = buildBackend ?? "uv_build"
        self.requires = requires ?? []
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj["build-backend"] = buildBackend
        obj.requires = requires
        return obj.jsValue
    }

    static func construct(from value: JSValue) -> Self? {
        guard let js = value.object else { return nil }
        return .init(
            buildBackend: js["build-backend"],
            requires: js.requires
        )
    }

    enum CodingKeys: String, CodingKey {
        case buildBackend = "build-backend"
        case requires
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.buildBackend = try c.decodeIfPresent(String.self, forKey: .buildBackend) ?? "uv_build"
        self.requires = try c.decodeIfPresent([String].self, forKey: .requires) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(buildBackend, forKey: .buildBackend)
        try c.encode(requires, forKey: .requires)
    }
}

// MARK: - [dependency-groups]

@Reactive
final class DependencyGroupsSection: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var dev: [String]
    var iphoneos: [String]

    init(dev: [String]? = nil, iphoneos: [String]? = nil) {
        self.dev = dev ?? []
        self.iphoneos = iphoneos ?? []
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(
            dev: obj.dev,
            iphoneos: obj.iphoneos
        )
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.dev = dev
        obj.iphoneos = iphoneos
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case dev, iphoneos
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.dev = try c.decodeIfPresent([String].self, forKey: .dev) ?? []
        self.iphoneos = try c.decodeIfPresent([String].self, forKey: .iphoneos) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(dev, forKey: .dev)
        try c.encode(iphoneos, forKey: .iphoneos)
    }
}

// MARK: - [tool.uv]

@Reactive
final class UVSection: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var indexStrategy: IndexStrategy
    var indexURL: String
    var indexEnabled: Bool
    var sources: [String: String]
    var extraIndexURL: [String]
    var workspaceMembers: [String]
    
    init(
        indexStrategy: IndexStrategy? = nil,
        indexURL: String? = nil,
        indexEnabled: Bool? = nil,
        sources: [String : String]? = nil,
        extraIndexURL: [String]? = nil,
        workspaceMembers: [String]? = nil
    ) {
        self.indexStrategy = indexStrategy ?? .unsafe_best_match
        self.indexURL = indexURL ?? ""
        self.indexEnabled = indexEnabled ?? false
        self.sources = sources ?? [:]
        self.extraIndexURL = extraIndexURL ?? []
        self.workspaceMembers = workspaceMembers ?? []
    }
    
    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        let strategyStr: String? = obj["index-strategy"].fromJSValue()
        return Self.init(
            indexStrategy: strategyStr.flatMap { IndexStrategy(rawValue: $0) },
            indexURL: obj["index-url"],
            indexEnabled: obj["index-enabled"],
            sources: obj.sources,
            extraIndexURL: obj["extra-index-url"],
            workspaceMembers: obj["workspace-members"]
        )
    }
    
    var jsValue: JSValue {
        let obj = JSObject()
        obj["index-strategy"] = indexStrategy.rawValue
        obj["index-url"] = indexURL
        obj["index-enabled"] = indexEnabled
        obj.sources = sources
        obj["extra-index-url"] = extraIndexURL
        obj["workspace-members"] = workspaceMembers
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case indexStrategy = "index-strategy"
        case indexURL = "index-url"
        case indexEnabled = "index-enabled"
        case sources
        case extraIndexURL = "extra-index-url"
        case workspaceMembers = "workspace-members"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.indexStrategy = try c.decodeIfPresent(IndexStrategy.self, forKey: .indexStrategy) ?? .unsafe_best_match
        self.indexURL = try c.decodeIfPresent(String.self, forKey: .indexURL) ?? ""
        self.indexEnabled = try c.decodeIfPresent(Bool.self, forKey: .indexEnabled) ?? false
        self.sources = try c.decodeIfPresent([String: String].self, forKey: .sources) ?? [:]
        self.extraIndexURL = try c.decodeIfPresent([String].self, forKey: .extraIndexURL) ?? []
        self.workspaceMembers = try c.decodeIfPresent([String].self, forKey: .workspaceMembers) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(indexStrategy, forKey: .indexStrategy)
        try c.encode(indexURL, forKey: .indexURL)
        try c.encode(indexEnabled, forKey: .indexEnabled)
        try c.encode(sources, forKey: .sources)
        try c.encode(extraIndexURL, forKey: .extraIndexURL)
        try c.encode(workspaceMembers, forKey: .workspaceMembers)
    }
}

// MARK: - [tool.psproject]

@Reactive
final class PSProjectSection: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var appName: String
    var backends: [String]
    var copyMainPy: Bool
    var cythonized: Bool
    var pipInstallApp: Bool
    var iosBackends: [String]
    var entitlements: Entitlements
    var infoPlist: InfoPlist
    var macos: [String: String]
    var swiftPackages: [String: String]
    /// Data URL (or backend-provided path) for the iOS app icon. Field name
    /// mirrors kivy's `data.icon` — see `IMiscellaneous` in the reference app.
    var icon: String
    /// Data URL (or backend-provided path) for the iOS presplash image. Mirrors kivy's `data.presplash`.
    var presplash: String
    /// Hex color for the presplash background. Mirrors kivy's `data.presplash_color`.
    var presplashColor: String
    /// List of permission identifiers. Mirrors kivy's `datamodel.ios_permissions`
    /// (see `IPermissions`) — reference app fetches known permission names
    /// from an API for a picker; here it's a plain add/remove list since
    /// there's no such API wired up.
    var iosPermissions: [String]

    init(
        appName: String? = nil,
        backends: [String]? = nil,
        copyMainPy: Bool? = nil,
        cythonized: Bool? = nil,
        pipInstallApp: Bool? = nil,
        iosBackends: [String]? = nil,
        entitlements: Entitlements? = nil,
        infoPlist: InfoPlist? = nil,
        macos: [String : String]? = nil,
        swiftPackages: [String : String]? = nil,
        icon: String? = nil,
        presplash: String? = nil,
        presplashColor: String? = nil,
        iosPermissions: [String]? = nil
    ) {
        self.appName = appName ?? ""
        self.backends = backends ?? []
        self.copyMainPy = copyMainPy ?? true
        self.cythonized = cythonized ?? false
        self.pipInstallApp = pipInstallApp ?? true
        self.iosBackends = iosBackends ?? []
        self.entitlements = entitlements ?? [:]
        self.infoPlist = infoPlist ?? [:]
        self.macos = macos ?? [:]
        self.swiftPackages = swiftPackages ?? [:]
        self.icon = icon ?? ""
        self.presplash = presplash ?? ""
        self.presplashColor = presplashColor ?? "#FFFFFF"
        self.iosPermissions = iosPermissions ?? []
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(
            appName: obj.app_name,
            backends: obj.backends,
            copyMainPy: obj.copy__main__py,
            cythonized: obj.cythonized,
            pipInstallApp: obj.pip_install_app,
            iosBackends: obj.ios_backends,
            entitlements: obj.entitlements,
            infoPlist: obj.info_plist,
            macos: obj.macos,
            swiftPackages: obj.swift_packages,
            icon: obj.icon,
            presplash: obj.presplash,
            presplashColor: obj.presplash_color,
            iosPermissions: obj.ios_permissions
        )
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.app_name = appName
        obj.backends = backends
        obj.copy__main__py = copyMainPy
        obj.cythonized = cythonized
        obj.pip_install_app = pipInstallApp
        obj.ios_backends = iosBackends
        obj.entitlements = entitlements
        obj.info_plist = infoPlist
        obj.macos = macos
        obj.swift_packages = swiftPackages
        obj.icon = icon
        obj.presplash = presplash
        obj.presplash_color = presplashColor
        obj.ios_permissions = iosPermissions
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case backends
        case copyMainPy = "copy__main__py"
        case cythonized
        case pipInstallApp = "pip_install_app"
        case iosBackends = "ios_backends"
        case entitlements
        case infoPlist = "info_plist"
        case macos
        case swiftPackages = "swift_packages"
        case icon
        case presplash
        case presplashColor = "presplash_color"
        case iosPermissions = "ios_permissions"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.appName = try c.decodeIfPresent(String.self, forKey: .appName) ?? ""
        self.backends = try c.decodeIfPresent([String].self, forKey: .backends) ?? []
        self.copyMainPy = try c.decodeIfPresent(Bool.self, forKey: .copyMainPy) ?? true
        self.cythonized = try c.decodeIfPresent(Bool.self, forKey: .cythonized) ?? false
        self.pipInstallApp = try c.decodeIfPresent(Bool.self, forKey: .pipInstallApp) ?? true
        self.iosBackends = try c.decodeIfPresent([String].self, forKey: .iosBackends) ?? []
        self.entitlements = try c.decodeIfPresent(Entitlements.self, forKey: .entitlements) ?? [:]
        self.infoPlist = try c.decodeIfPresent(InfoPlist.self, forKey: .infoPlist) ?? [:]
        self.macos = try c.decodeIfPresent([String: String].self, forKey: .macos) ?? [:]
        self.swiftPackages = try c.decodeIfPresent([String: String].self, forKey: .swiftPackages) ?? [:]
        self.icon = try c.decodeIfPresent(String.self, forKey: .icon) ?? ""
        self.presplash = try c.decodeIfPresent(String.self, forKey: .presplash) ?? ""
        self.presplashColor = try c.decodeIfPresent(String.self, forKey: .presplashColor) ?? "#FFFFFF"
        self.iosPermissions = try c.decodeIfPresent([String].self, forKey: .iosPermissions) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(appName, forKey: .appName)
        try c.encode(backends, forKey: .backends)
        try c.encode(copyMainPy, forKey: .copyMainPy)
        try c.encode(cythonized, forKey: .cythonized)
        try c.encode(pipInstallApp, forKey: .pipInstallApp)
        try c.encode(iosBackends, forKey: .iosBackends)
        try c.encode(entitlements, forKey: .entitlements)
        try c.encode(infoPlist, forKey: .infoPlist)
        try c.encode(macos, forKey: .macos)
        try c.encode(swiftPackages, forKey: .swiftPackages)
        try c.encode(icon, forKey: .icon)
        try c.encode(presplash, forKey: .presplash)
        try c.encode(presplashColor, forKey: .presplashColor)
        try c.encode(iosPermissions, forKey: .iosPermissions)
    }
}
