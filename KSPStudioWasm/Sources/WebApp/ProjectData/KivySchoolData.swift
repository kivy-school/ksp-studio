import Reactivity
import JavaScriptKit
import JavaScriptKitExtensions
import Foundation

// Swift mirror of `ksproject/src/ksproject_utils/pyproject_toml.py`. Same
// class layout and nesting as the Python model (`KivySchoolData.AppleData`,
// `.IosData`/`.MacosData`, `AndroidData.Arch`/`.ServiceData`, `ToolData`,
// `Project`, `PyProjectToml`) so the two stay easy to compare field-by-field.
// Not wired into `ProjectModel`/the UI yet — this is just the data shape.

// MARK: - [project]

@Reactive
final class Project: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var name: String

    init(name: String? = nil) {
        self.name = name ?? ""
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(name: obj.name)
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.name = name
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
    }
}

// MARK: - [tool]

@Reactive
final class ToolData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var kivySchool: KivySchoolData?

    init(kivySchool: KivySchoolData? = nil) {
        self.kivySchool = kivySchool
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(kivySchool: obj["kivy-school"])
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj["kivy-school"] = kivySchool
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case kivySchool = "kivy-school"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.kivySchool = try c.decodeIfPresent(KivySchoolData.self, forKey: .kivySchool)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kivySchool, forKey: .kivySchool)
    }
}

// MARK: - pyproject.toml (root)

@Reactive
final class PyProjectToml: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var project: Project
    var tool: ToolData

    init(project: Project? = nil, tool: ToolData? = nil) {
        self.project = project ?? .init()
        self.tool = tool ?? .init()
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(project: obj.project, tool: obj.tool)
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.project = project
        obj.tool = tool
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case project, tool
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.project = try c.decodeIfPresent(Project.self, forKey: .project) ?? .init()
        self.tool = try c.decodeIfPresent(ToolData.self, forKey: .tool) ?? .init()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(project, forKey: .project)
        try c.encode(tool, forKey: .tool)
    }
}

// MARK: - [tool.kivy-school]

@Reactive
final class KivySchoolData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var appName: String?
    var apple: AppleData
    var android: AndroidData?
    var bootstrap: String

    init(
        appName: String? = nil,
        apple: AppleData? = nil,
        android: AndroidData? = nil,
        bootstrap: String? = nil
    ) {
        self.appName = appName
        self.apple = apple ?? .init()
        self.android = android
        self.bootstrap = bootstrap ?? "kivy"
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(
            appName: obj.app_name,
            apple: obj.apple,
            android: obj.android,
            bootstrap: obj.bootstrap
        )
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.app_name = appName
        obj.apple = apple
        obj.android = android
        obj.bootstrap = bootstrap
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case apple, android, bootstrap
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.appName = try c.decodeIfPresent(String.self, forKey: .appName)
        self.apple = try c.decodeIfPresent(AppleData.self, forKey: .apple) ?? .init()
        self.android = try c.decodeIfPresent(AndroidData.self, forKey: .android)
        self.bootstrap = try c.decodeIfPresent(String.self, forKey: .bootstrap) ?? "kivy"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(appName, forKey: .appName)
        try c.encode(apple, forKey: .apple)
        try c.encode(android, forKey: .android)
        try c.encode(bootstrap, forKey: .bootstrap)
    }
}

// MARK: - [tool.kivy-school.ios] / [tool.kivy-school.macos]

extension KivySchoolData {
    @Reactive
    final class AppleData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var ios: IosData?
        var macos: MacosData?

        init(ios: IosData? = nil, macos: MacosData? = nil) {
            self.ios = ios
            self.macos = macos
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            return Self.init(ios: obj.ios, macos: obj.macos)
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.ios = ios
            obj.macos = macos
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case ios, macos
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.ios = try c.decodeIfPresent(IosData.self, forKey: .ios)
            self.macos = try c.decodeIfPresent(MacosData.self, forKey: .macos)
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(ios, forKey: .ios)
            try c.encode(macos, forKey: .macos)
        }
    }
}

extension KivySchoolData.AppleData {
    @Reactive
    final class IosData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var bundleId: String
        var infoPlist: InfoPlist
        var entitlements: Entitlements
        var permissions: [String]
        var frameworks: [String]
        var siteFrameworks: [String]
        var developerTeam: String?
        var minimumDeployment: String?
        var preBuild: String?
        var postBuild: String?

        init(
            bundleId: String? = nil,
            infoPlist: InfoPlist? = nil,
            entitlements: Entitlements? = nil,
            permissions: [String]? = nil,
            frameworks: [String]? = nil,
            siteFrameworks: [String]? = nil,
            developerTeam: String? = nil,
            minimumDeployment: String? = nil,
            preBuild: String? = nil,
            postBuild: String? = nil
        ) {
            self.bundleId = bundleId ?? ""
            self.infoPlist = infoPlist ?? [:]
            self.entitlements = entitlements ?? [:]
            self.permissions = permissions ?? []
            self.frameworks = frameworks ?? []
            self.siteFrameworks = siteFrameworks ?? []
            self.developerTeam = developerTeam
            self.minimumDeployment = minimumDeployment
            self.preBuild = preBuild
            self.postBuild = postBuild
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            return Self.init(
                bundleId: obj.bundle_id,
                infoPlist: obj.info_plist,
                entitlements: obj.entitlements,
                permissions: obj.permissions,
                frameworks: obj.frameworks,
                siteFrameworks: obj.site_frameworks,
                developerTeam: obj.developer_team,
                minimumDeployment: obj.minimum_deployment,
                preBuild: obj.pre_build,
                postBuild: obj.post_build
            )
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.bundle_id = bundleId
            obj.info_plist = infoPlist
            obj.entitlements = entitlements
            obj.permissions = permissions
            obj.frameworks = frameworks
            obj.site_frameworks = siteFrameworks
            obj.developer_team = developerTeam
            obj.minimum_deployment = minimumDeployment
            obj.pre_build = preBuild
            obj.post_build = postBuild
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case bundleId = "bundle_id"
            case infoPlist = "info_plist"
            case entitlements, permissions, frameworks
            case siteFrameworks = "site_frameworks"
            case developerTeam = "developer_team"
            case minimumDeployment = "minimum_deployment"
            case preBuild = "pre_build"
            case postBuild = "post_build"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.bundleId = try c.decodeIfPresent(String.self, forKey: .bundleId) ?? ""
            self.infoPlist = try c.decodeIfPresent(InfoPlist.self, forKey: .infoPlist) ?? [:]
            self.entitlements = try c.decodeIfPresent(Entitlements.self, forKey: .entitlements) ?? [:]
            self.permissions = try c.decodeIfPresent([String].self, forKey: .permissions) ?? []
            self.frameworks = try c.decodeIfPresent([String].self, forKey: .frameworks) ?? []
            self.siteFrameworks = try c.decodeIfPresent([String].self, forKey: .siteFrameworks) ?? []
            self.developerTeam = try c.decodeIfPresent(String.self, forKey: .developerTeam)
            self.minimumDeployment = try c.decodeIfPresent(String.self, forKey: .minimumDeployment)
            self.preBuild = try c.decodeIfPresent(String.self, forKey: .preBuild)
            self.postBuild = try c.decodeIfPresent(String.self, forKey: .postBuild)
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(bundleId, forKey: .bundleId)
            try c.encode(infoPlist, forKey: .infoPlist)
            try c.encode(entitlements, forKey: .entitlements)
            try c.encode(permissions, forKey: .permissions)
            try c.encode(frameworks, forKey: .frameworks)
            try c.encode(siteFrameworks, forKey: .siteFrameworks)
            try c.encode(developerTeam, forKey: .developerTeam)
            try c.encode(minimumDeployment, forKey: .minimumDeployment)
            try c.encode(preBuild, forKey: .preBuild)
            try c.encode(postBuild, forKey: .postBuild)
        }
    }

    @Reactive
    final class MacosData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var bundleId: String
        var infoPlist: InfoPlist
        var entitlements: Entitlements
        var permissions: [String]
        var developerTeam: String?
        var minimumDeployment: String?
        var archs: [String]
        var preBuild: String?
        var postBuild: String?

        init(
            bundleId: String? = nil,
            infoPlist: InfoPlist? = nil,
            entitlements: Entitlements? = nil,
            permissions: [String]? = nil,
            developerTeam: String? = nil,
            minimumDeployment: String? = nil,
            archs: [String]? = nil,
            preBuild: String? = nil,
            postBuild: String? = nil
        ) {
            self.bundleId = bundleId ?? ""
            self.infoPlist = infoPlist ?? [:]
            self.entitlements = entitlements ?? [:]
            self.permissions = permissions ?? []
            self.developerTeam = developerTeam
            self.minimumDeployment = minimumDeployment
            self.archs = archs ?? ["arm64", "x86_64"]
            self.preBuild = preBuild
            self.postBuild = postBuild
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            return Self.init(
                bundleId: obj.bundle_id,
                infoPlist: obj.info_plist,
                entitlements: obj.entitlements,
                permissions: obj.permissions,
                developerTeam: obj.developer_team,
                minimumDeployment: obj.minimum_deployment,
                archs: obj.archs,
                preBuild: obj.pre_build,
                postBuild: obj.post_build
            )
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.bundle_id = bundleId
            obj.info_plist = infoPlist
            obj.entitlements = entitlements
            obj.permissions = permissions
            obj.developer_team = developerTeam
            obj.minimum_deployment = minimumDeployment
            obj.archs = archs
            obj.pre_build = preBuild
            obj.post_build = postBuild
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case bundleId = "bundle_id"
            case infoPlist = "info_plist"
            case entitlements, permissions
            case developerTeam = "developer_team"
            case minimumDeployment = "minimum_deployment"
            case archs
            case preBuild = "pre_build"
            case postBuild = "post_build"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.bundleId = try c.decodeIfPresent(String.self, forKey: .bundleId) ?? ""
            self.infoPlist = try c.decodeIfPresent(InfoPlist.self, forKey: .infoPlist) ?? [:]
            self.entitlements = try c.decodeIfPresent(Entitlements.self, forKey: .entitlements) ?? [:]
            self.permissions = try c.decodeIfPresent([String].self, forKey: .permissions) ?? []
            self.developerTeam = try c.decodeIfPresent(String.self, forKey: .developerTeam)
            self.minimumDeployment = try c.decodeIfPresent(String.self, forKey: .minimumDeployment)
            self.archs = try c.decodeIfPresent([String].self, forKey: .archs) ?? ["arm64", "x86_64"]
            self.preBuild = try c.decodeIfPresent(String.self, forKey: .preBuild)
            self.postBuild = try c.decodeIfPresent(String.self, forKey: .postBuild)
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(bundleId, forKey: .bundleId)
            try c.encode(infoPlist, forKey: .infoPlist)
            try c.encode(entitlements, forKey: .entitlements)
            try c.encode(permissions, forKey: .permissions)
            try c.encode(developerTeam, forKey: .developerTeam)
            try c.encode(minimumDeployment, forKey: .minimumDeployment)
            try c.encode(archs, forKey: .archs)
            try c.encode(preBuild, forKey: .preBuild)
            try c.encode(postBuild, forKey: .postBuild)
        }
    }
}

// MARK: - [tool.kivy-school.android]

extension KivySchoolData {
    @Reactive
    final class AndroidData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var packageName: String
        var archs: [Arch]
        var api: Int?
        var minApi: Int?
        var sdk: String?
        var ndk: String?
        var ndkApi: Int?
        var sdkPath: String?
        var ndkPath: String?
        var javaPath: String?
        var globalTools: Bool
        var globalToolsPath: String?
        var icon: String?
        var presplash: String?
        var presplashColor: String
        var presplashLottie: String?
        var permissions: [String]
        var metaData: [String: String]
        var gradleDependencies: [String]
        var gradlePlugins: [String]
        var services: [ServiceData]
        var versionCode: Int
        var versionName: String
        var includeFiles: [IncludeFileEntry]
        var preBuild: String?
        var postBuild: String?
        var byteCompilePython: Bool
        var universalApk: Bool

        init(
            packageName: String? = nil,
            archs: [Arch]? = nil,
            api: Int? = nil,
            minApi: Int? = nil,
            sdk: String? = nil,
            ndk: String? = nil,
            ndkApi: Int? = nil,
            sdkPath: String? = nil,
            ndkPath: String? = nil,
            javaPath: String? = nil,
            globalTools: Bool? = nil,
            globalToolsPath: String? = nil,
            icon: String? = nil,
            presplash: String? = nil,
            presplashColor: String? = nil,
            presplashLottie: String? = nil,
            permissions: [String]? = nil,
            metaData: [String: String]? = nil,
            gradleDependencies: [String]? = nil,
            gradlePlugins: [String]? = nil,
            services: [ServiceData]? = nil,
            versionCode: Int? = nil,
            versionName: String? = nil,
            includeFiles: [IncludeFileEntry]? = nil,
            preBuild: String? = nil,
            postBuild: String? = nil,
            byteCompilePython: Bool? = nil,
            universalApk: Bool? = nil
        ) {
            self.packageName = packageName ?? ""
            self.archs = archs ?? []
            self.api = api
            self.minApi = minApi
            self.sdk = sdk
            self.ndk = ndk
            self.ndkApi = ndkApi
            self.sdkPath = sdkPath
            self.ndkPath = ndkPath
            self.javaPath = javaPath
            self.globalTools = globalTools ?? false
            self.globalToolsPath = globalToolsPath
            self.icon = icon
            self.presplash = presplash
            self.presplashColor = presplashColor ?? "#FFFFFF"
            self.presplashLottie = presplashLottie
            self.permissions = permissions ?? []
            self.metaData = metaData ?? [:]
            self.gradleDependencies = gradleDependencies ?? []
            self.gradlePlugins = gradlePlugins ?? []
            self.services = services ?? []
            self.versionCode = versionCode ?? 1
            self.versionName = versionName ?? "1.0"
            self.includeFiles = includeFiles ?? []
            self.preBuild = preBuild
            self.postBuild = postBuild
            self.byteCompilePython = byteCompilePython ?? true
            self.universalApk = universalApk ?? true
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            let archStrings: [String] = obj.archs ?? []
            return Self.init(
                packageName: obj.package_name,
                archs: archStrings.compactMap { Arch(rawValue: $0) },
                api: obj.api,
                minApi: obj.min_api,
                sdk: obj.sdk,
                ndk: obj.ndk,
                ndkApi: obj.ndk_api,
                sdkPath: obj.sdk_path,
                ndkPath: obj.ndk_path,
                javaPath: obj.java_path,
                globalTools: obj.global_tools,
                globalToolsPath: obj.global_tools_path,
                icon: obj.icon,
                presplash: obj.presplash,
                presplashColor: obj.presplash_color,
                presplashLottie: obj.presplash_lottie,
                permissions: obj.permissions,
                metaData: obj.meta_data,
                gradleDependencies: obj.gradle_dependencies,
                gradlePlugins: obj.gradle_plugins,
                services: obj.services,
                versionCode: obj.version_code,
                versionName: obj.version_name,
                includeFiles: obj.include_files,
                preBuild: obj.pre_build,
                postBuild: obj.post_build,
                byteCompilePython: obj.byte_compile_python,
                universalApk: obj.universal_apk
            )
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.package_name = packageName
            obj.archs = archs.map(\.rawValue)
            obj.api = api
            obj.min_api = minApi
            obj.sdk = sdk
            obj.ndk = ndk
            obj.ndk_api = ndkApi
            obj.sdk_path = sdkPath
            obj.ndk_path = ndkPath
            obj.java_path = javaPath
            obj.global_tools = globalTools
            obj.global_tools_path = globalToolsPath
            obj.icon = icon
            obj.presplash = presplash
            obj.presplash_color = presplashColor
            obj.presplash_lottie = presplashLottie
            obj.permissions = permissions
            obj.meta_data = metaData
            obj.gradle_dependencies = gradleDependencies
            obj.gradle_plugins = gradlePlugins
            obj.services = services
            obj.version_code = versionCode
            obj.version_name = versionName
            obj.include_files = includeFiles
            obj.pre_build = preBuild
            obj.post_build = postBuild
            obj.byte_compile_python = byteCompilePython
            obj.universal_apk = universalApk
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case packageName = "package_name"
            case archs, api
            case minApi = "min_api"
            case sdk, ndk
            case ndkApi = "ndk_api"
            case sdkPath = "sdk_path"
            case ndkPath = "ndk_path"
            case javaPath = "java_path"
            case globalTools = "global_tools"
            case globalToolsPath = "global_tools_path"
            case icon, presplash
            case presplashColor = "presplash_color"
            case presplashLottie = "presplash_lottie"
            case permissions
            case metaData = "meta_data"
            case gradleDependencies = "gradle_dependencies"
            case gradlePlugins = "gradle_plugins"
            case services
            case versionCode = "version_code"
            case versionName = "version_name"
            case includeFiles = "include_files"
            case preBuild = "pre_build"
            case postBuild = "post_build"
            case byteCompilePython = "byte_compile_python"
            case universalApk = "universal_apk"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.packageName = try c.decodeIfPresent(String.self, forKey: .packageName) ?? ""
            self.archs = try c.decodeIfPresent([Arch].self, forKey: .archs) ?? []
            self.api = try c.decodeIfPresent(Int.self, forKey: .api)
            self.minApi = try c.decodeIfPresent(Int.self, forKey: .minApi)
            self.sdk = try c.decodeIfPresent(String.self, forKey: .sdk)
            self.ndk = try c.decodeIfPresent(String.self, forKey: .ndk)
            self.ndkApi = try c.decodeIfPresent(Int.self, forKey: .ndkApi)
            self.sdkPath = try c.decodeIfPresent(String.self, forKey: .sdkPath)
            self.ndkPath = try c.decodeIfPresent(String.self, forKey: .ndkPath)
            self.javaPath = try c.decodeIfPresent(String.self, forKey: .javaPath)
            self.globalTools = try c.decodeIfPresent(Bool.self, forKey: .globalTools) ?? false
            self.globalToolsPath = try c.decodeIfPresent(String.self, forKey: .globalToolsPath)
            self.icon = try c.decodeIfPresent(String.self, forKey: .icon)
            self.presplash = try c.decodeIfPresent(String.self, forKey: .presplash)
            self.presplashColor = try c.decodeIfPresent(String.self, forKey: .presplashColor) ?? "#FFFFFF"
            self.presplashLottie = try c.decodeIfPresent(String.self, forKey: .presplashLottie)
            self.permissions = try c.decodeIfPresent([String].self, forKey: .permissions) ?? []
            self.metaData = try c.decodeIfPresent([String: String].self, forKey: .metaData) ?? [:]
            self.gradleDependencies = try c.decodeIfPresent([String].self, forKey: .gradleDependencies) ?? []
            self.gradlePlugins = try c.decodeIfPresent([String].self, forKey: .gradlePlugins) ?? []
            self.services = try c.decodeIfPresent([ServiceData].self, forKey: .services) ?? []
            self.versionCode = try c.decodeIfPresent(Int.self, forKey: .versionCode) ?? 1
            self.versionName = try c.decodeIfPresent(String.self, forKey: .versionName) ?? "1.0"
            self.includeFiles = try c.decodeIfPresent([IncludeFileEntry].self, forKey: .includeFiles) ?? []
            self.preBuild = try c.decodeIfPresent(String.self, forKey: .preBuild)
            self.postBuild = try c.decodeIfPresent(String.self, forKey: .postBuild)
            self.byteCompilePython = try c.decodeIfPresent(Bool.self, forKey: .byteCompilePython) ?? true
            self.universalApk = try c.decodeIfPresent(Bool.self, forKey: .universalApk) ?? true
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(packageName, forKey: .packageName)
            try c.encode(archs, forKey: .archs)
            try c.encode(api, forKey: .api)
            try c.encode(minApi, forKey: .minApi)
            try c.encode(sdk, forKey: .sdk)
            try c.encode(ndk, forKey: .ndk)
            try c.encode(ndkApi, forKey: .ndkApi)
            try c.encode(sdkPath, forKey: .sdkPath)
            try c.encode(ndkPath, forKey: .ndkPath)
            try c.encode(javaPath, forKey: .javaPath)
            try c.encode(globalTools, forKey: .globalTools)
            try c.encode(globalToolsPath, forKey: .globalToolsPath)
            try c.encode(icon, forKey: .icon)
            try c.encode(presplash, forKey: .presplash)
            try c.encode(presplashColor, forKey: .presplashColor)
            try c.encode(presplashLottie, forKey: .presplashLottie)
            try c.encode(permissions, forKey: .permissions)
            try c.encode(metaData, forKey: .metaData)
            try c.encode(gradleDependencies, forKey: .gradleDependencies)
            try c.encode(gradlePlugins, forKey: .gradlePlugins)
            try c.encode(services, forKey: .services)
            try c.encode(versionCode, forKey: .versionCode)
            try c.encode(versionName, forKey: .versionName)
            try c.encode(includeFiles, forKey: .includeFiles)
            try c.encode(preBuild, forKey: .preBuild)
            try c.encode(postBuild, forKey: .postBuild)
            try c.encode(byteCompilePython, forKey: .byteCompilePython)
            try c.encode(universalApk, forKey: .universalApk)
        }
    }
}

extension KivySchoolData.AndroidData {
    /// Toggle-shaped view onto `sdkPath`/`ndkPath`/`javaPath`/`globalToolsPath`:
    /// `nil` reads as off, switching on seeds an empty string, switching off
    /// clears back to `nil` — matches kivy's own `active: path != None`
    /// pattern for these 4 fields. Lives on the model (not the view) since
    /// it's a plain derivation of already-reactive-tracked stored properties.
    var sdkPathEnabled: Bool {
        get { sdkPath != nil }
        set { sdkPath = newValue ? "" : nil }
    }
    var ndkPathEnabled: Bool {
        get { ndkPath != nil }
        set { ndkPath = newValue ? "" : nil }
    }
    var javaPathEnabled: Bool {
        get { javaPath != nil }
        set { javaPath = newValue ? "" : nil }
    }
    var globalToolsPathEnabled: Bool {
        get { globalToolsPath != nil }
        set { globalToolsPath = newValue ? "" : nil }
    }

    enum Arch: String, CaseIterable, Codable, Equatable {
        case arm64_v8a = "arm64-v8a"
        case x86_64 = "x86_64"
    }

    @Reactive
    final class ServiceData: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var name: String
        var entrypoint: String
        var foreground: Bool
        var foregroundServiceType: String?
        var startType: String
        var notificationTitle: String
        var notificationText: String
        var notificationIcon: String

        init(
            name: String? = nil,
            entrypoint: String? = nil,
            foreground: Bool? = nil,
            foregroundServiceType: String? = nil,
            startType: String? = nil,
            notificationTitle: String? = nil,
            notificationText: String? = nil,
            notificationIcon: String? = nil
        ) {
            let resolvedName = name ?? ""
            self.name = resolvedName
            // Mirrors the Python model's normalization: accepts a "/"-style
            // path or a ".py" filename and folds it down to a module path.
            self.entrypoint = (entrypoint ?? "service_main")
                .replacingOccurrences(of: "/", with: ".")
                .replacingOccurrences(of: ".py", with: "")
            self.foreground = foreground ?? false
            self.foregroundServiceType = foregroundServiceType
            self.startType = startType ?? "START_NOT_STICKY"
            self.notificationTitle = notificationTitle ?? "\(resolvedName) is running"
            self.notificationText = notificationText ?? "Background task active"
            self.notificationIcon = notificationIcon ?? "stat_notify_sync"
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            return Self.init(
                name: obj.name,
                entrypoint: obj.entrypoint,
                foreground: obj.foreground,
                foregroundServiceType: obj.foreground_service_type,
                startType: obj.start_type,
                notificationTitle: obj.notification_title,
                notificationText: obj.notification_text,
                notificationIcon: obj.notification_icon
            )
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.name = name
            obj.entrypoint = entrypoint
            obj.foreground = foreground
            obj.foreground_service_type = foregroundServiceType
            obj.start_type = startType
            obj.notification_title = notificationTitle
            obj.notification_text = notificationText
            obj.notification_icon = notificationIcon
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case name, entrypoint, foreground
            case foregroundServiceType = "foreground_service_type"
            case startType = "start_type"
            case notificationTitle = "notification_title"
            case notificationText = "notification_text"
            case notificationIcon = "notification_icon"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            let resolvedName = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
            self.name = resolvedName
            self.entrypoint = (try c.decodeIfPresent(String.self, forKey: .entrypoint) ?? "service_main")
                .replacingOccurrences(of: "/", with: ".")
                .replacingOccurrences(of: ".py", with: "")
            self.foreground = try c.decodeIfPresent(Bool.self, forKey: .foreground) ?? false
            self.foregroundServiceType = try c.decodeIfPresent(String.self, forKey: .foregroundServiceType)
            self.startType = try c.decodeIfPresent(String.self, forKey: .startType) ?? "START_NOT_STICKY"
            self.notificationTitle = try c.decodeIfPresent(String.self, forKey: .notificationTitle) ?? "\(resolvedName) is running"
            self.notificationText = try c.decodeIfPresent(String.self, forKey: .notificationText) ?? "Background task active"
            self.notificationIcon = try c.decodeIfPresent(String.self, forKey: .notificationIcon) ?? "stat_notify_sync"
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(name, forKey: .name)
            try c.encode(entrypoint, forKey: .entrypoint)
            try c.encode(foreground, forKey: .foreground)
            try c.encode(foregroundServiceType, forKey: .foregroundServiceType)
            try c.encode(startType, forKey: .startType)
            try c.encode(notificationTitle, forKey: .notificationTitle)
            try c.encode(notificationText, forKey: .notificationText)
            try c.encode(notificationIcon, forKey: .notificationIcon)
        }
    }

    /// Mirrors Python's `include_files: list[tuple[str, list[str]]]`. Modeled
    /// as `{dest, sources}` on the wire rather than a positional tuple/array —
    /// simpler to round-trip reliably through JSValue, and (like the rest of
    /// this file) not yet verified against a real backend payload.
    @Reactive
    final class IncludeFileEntry: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
        var dest: String
        var sources: [String]

        init(dest: String? = nil, sources: [String]? = nil) {
            self.dest = dest ?? ""
            self.sources = sources ?? []
        }

        static func construct(from value: JSValue) -> Self? {
            guard let obj = value.object else { return nil }
            return Self.init(dest: obj.dest, sources: obj.sources)
        }

        var jsValue: JSValue {
            let obj = JSObject()
            obj.dest = dest
            obj.sources = sources
            return obj.jsValue
        }

        enum CodingKeys: String, CodingKey {
            case dest, sources
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.dest = try c.decodeIfPresent(String.self, forKey: .dest) ?? ""
            self.sources = try c.decodeIfPresent([String].self, forKey: .sources) ?? []
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(dest, forKey: .dest)
            try c.encode(sources, forKey: .sources)
        }
    }
}
