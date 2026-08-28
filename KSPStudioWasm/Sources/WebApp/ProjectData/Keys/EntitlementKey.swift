//
//  EntitlementKey.swift
//  PSProjectConfigWasm
//


import Foundation

/// All common Xcode entitlement keys, grouped by category.
public enum EntitlementKey: String, CaseIterable, Sendable {

    // MARK: - App Sandbox

    case appSandbox                        = "com.apple.security.app-sandbox"
    case sandboxNetworkClient              = "com.apple.security.network.client"
    case sandboxNetworkServer              = "com.apple.security.network.server"
    case sandboxFilesReadOnly              = "com.apple.security.files.user-selected.read-only"
    case sandboxFilesReadWrite             = "com.apple.security.files.user-selected.read-write"
    case sandboxFilesDownloadsReadOnly     = "com.apple.security.files.downloads.read-only"
    case sandboxFilesDownloadsReadWrite    = "com.apple.security.files.downloads.read-write"
    case sandboxFilesPicturesReadOnly      = "com.apple.security.assets.pictures.read-only"
    case sandboxFilesPicturesReadWrite     = "com.apple.security.assets.pictures.read-write"
    case sandboxFilesMusicReadOnly         = "com.apple.security.assets.music.read-only"
    case sandboxFilesMusicReadWrite        = "com.apple.security.assets.music.read-write"
    case sandboxFilesMoviesReadOnly        = "com.apple.security.assets.movies.read-only"
    case sandboxFilesMoviesReadWrite       = "com.apple.security.assets.movies.read-write"
    case sandboxAllFiles                   = "com.apple.security.files.all"
    case sandboxUSBAccess                  = "com.apple.security.device.usb"
    case sandboxSerialAccess               = "com.apple.security.device.serial"
    case sandboxPrinting                   = "com.apple.security.print"
    case sandboxCamera                     = "com.apple.security.device.camera"
    case sandboxMicrophone                 = "com.apple.security.device.audio-input"
    case sandboxBluetooth                  = "com.apple.security.device.bluetooth"
    case sandboxAddressBook                = "com.apple.security.personal-information.addressbook"
    case sandboxCalendars                  = "com.apple.security.personal-information.calendars"
    case sandboxLocation                   = "com.apple.security.personal-information.location"
    case sandboxAppleEvents                = "com.apple.security.automation.apple-events"
    case sandboxBookmarksDocument          = "com.apple.security.files.bookmarks.document-scope"
    case sandboxBookmarksApp               = "com.apple.security.files.bookmarks.app-scope"

    // MARK: - Hardened Runtime

    case allowJIT                          = "com.apple.security.cs.allow-jit"
    case allowUnsignedExecutableMemory     = "com.apple.security.cs.allow-unsigned-executable-memory"
    case allowDYLDEnvironmentVariables     = "com.apple.security.cs.allow-dyld-environment-variables"
    case disableLibraryValidation          = "com.apple.security.cs.disable-library-validation"
    case disableExecutablePageProtection   = "com.apple.security.cs.disable-executable-page-protection"
    case debugger                          = "com.apple.security.cs.debugger"
    case photosLibrary                     = "com.apple.security.personal-information.photos-library"

    // MARK: - App Groups

    case appGroups                         = "com.apple.security.application-groups"

    // MARK: - iCloud

    case iCloudContainers                  = "com.apple.developer.icloud-container-identifiers"
    case iCloudServices                    = "com.apple.developer.icloud-services"
    case iCloudKeyValueStore               = "com.apple.developer.ubiquity-kvstore-identifier"
    case iCloudContainerEnvironment        = "com.apple.developer.icloud-container-environment"

    // MARK: - Push Notifications

    case pushNotifications                 = "aps-environment"

    // MARK: - Apple Pay

    case applePay                          = "com.apple.developer.in-app-payments"

    // MARK: - Associated Domains

    case associatedDomains                 = "com.apple.developer.associated-domains"

    // MARK: - Keychain

    case keychainAccessGroups              = "keychain-access-groups"
    case keychainSharing                   = "com.apple.developer.keychain-access-groups"

    // MARK: - Network Extensions

    case networkExtensions                 = "com.apple.developer.networking.networkextension"
    case personalVPN                       = "com.apple.developer.networking.vpn.api"
    case dnsProxy                          = "com.apple.developer.networking.dns-proxy"
    case contentFilterProvider             = "com.apple.developer.networking.content-filter-provider"

    // MARK: - Multicast / Networking

    case multicast                         = "com.apple.developer.networking.multicast"
    case hotspotConfiguration              = "com.apple.developer.networking.HotspotConfiguration"
    case hotspotHelper                     = "com.apple.developer.networking.HotspotHelper"

    // MARK: - NFC

    case nfcTagReaderSession               = "com.apple.developer.nfc.readersession.formats"

    // MARK: - HealthKit

    case healthKit                         = "com.apple.developer.healthkit"
    case healthKitCapabilities             = "com.apple.developer.healthkit.access"
    case healthRecords                     = "com.apple.developer.healthkit.recalibrate-estimates"

    // MARK: - HomeKit

    case homeKit                           = "com.apple.developer.homekit"

    // MARK: - ClassKit

    case classKit                          = "com.apple.developer.ClassKit-environment"

    // MARK: - AutoFill

    case autoFillCredentialProvider         = "com.apple.developer.authentication-services.autofill-credential-provider"

    // MARK: - Siri

    case siri                              = "com.apple.developer.siri"

    // MARK: - Maps

    case maps                              = "com.apple.developer.maps"

    // MARK: - Game Center

    case gameCenter                        = "com.apple.developer.game-center"

    // MARK: - Wallet

    case wallet                            = "com.apple.developer.pass-type-identifiers"

    // MARK: - Sign In with Apple

    case signInWithApple                   = "com.apple.developer.applesignin"

    // MARK: - Fonts

    case fontInstallation                  = "com.apple.developer.user-fonts"

    // MARK: - System Extensions

    case systemExtension                   = "com.apple.developer.system-extension.install"
    case driverKitFamilies                 = "com.apple.developer.driverkit.family"

    // MARK: - Communication Notifications

    case communicationNotifications        = "com.apple.developer.usernotifications.communication"

    // MARK: - Time-Sensitive Notifications

    case timeSensitiveNotifications        = "com.apple.developer.usernotifications.time-sensitive"

    // MARK: - App Attest

    case appAttest                         = "com.apple.developer.devicecheck.appattest-environment"

    // MARK: - Extended Virtual Addressing

    case extendedVirtualAddressing         = "com.apple.developer.kernel.extended-virtual-addressing"
    case increasedMemoryLimit              = "com.apple.developer.kernel.increased-memory-limit"

    // MARK: - Background Tasks

    case backgroundModes                   = "com.apple.developer.background-modes"

    // MARK: - Inter-App Audio

    case interAppAudio                     = "inter-app-audio"

    // MARK: - Shared with You

    case sharedWithYou                     = "com.apple.developer.shared-with-you"

    // MARK: - WeatherKit

    case weatherKit                        = "com.apple.developer.weatherkit"

    // MARK: - Media Device Discovery

    case mediaDeviceDiscovery              = "com.apple.developer.media-device-discovery-extension"

    // MARK: - Group Activities

    case groupActivities                   = "com.apple.developer.group-session"

    // MARK: - App Intents

    case appIntents                        = "com.apple.developer.appintents"

    /// Human-readable label for this key.
    public var label: String {
        switch self {
        // Sandbox
        case .appSandbox:                     return "App Sandbox"
        case .sandboxNetworkClient:           return "Network Client"
        case .sandboxNetworkServer:           return "Network Server"
        case .sandboxFilesReadOnly:           return "User Files (Read)"
        case .sandboxFilesReadWrite:          return "User Files (Read/Write)"
        case .sandboxFilesDownloadsReadOnly:  return "Downloads (Read)"
        case .sandboxFilesDownloadsReadWrite: return "Downloads (Read/Write)"
        case .sandboxFilesPicturesReadOnly:   return "Pictures (Read)"
        case .sandboxFilesPicturesReadWrite:  return "Pictures (Read/Write)"
        case .sandboxFilesMusicReadOnly:      return "Music (Read)"
        case .sandboxFilesMusicReadWrite:     return "Music (Read/Write)"
        case .sandboxFilesMoviesReadOnly:     return "Movies (Read)"
        case .sandboxFilesMoviesReadWrite:    return "Movies (Read/Write)"
        case .sandboxAllFiles:                return "All Files"
        case .sandboxUSBAccess:               return "USB"
        case .sandboxSerialAccess:            return "Serial Port"
        case .sandboxPrinting:                return "Printing"
        case .sandboxCamera:                  return "Camera (Sandbox)"
        case .sandboxMicrophone:              return "Microphone (Sandbox)"
        case .sandboxBluetooth:               return "Bluetooth (Sandbox)"
        case .sandboxAddressBook:             return "Address Book (Sandbox)"
        case .sandboxCalendars:               return "Calendars (Sandbox)"
        case .sandboxLocation:                return "Location (Sandbox)"
        case .sandboxAppleEvents:             return "Apple Events"
        case .sandboxBookmarksDocument:       return "Bookmarks (Document)"
        case .sandboxBookmarksApp:            return "Bookmarks (App)"
        // Hardened Runtime
        case .allowJIT:                       return "Allow JIT"
        case .allowUnsignedExecutableMemory:  return "Unsigned Executable Memory"
        case .allowDYLDEnvironmentVariables:  return "DYLD Environment Variables"
        case .disableLibraryValidation:       return "Disable Library Validation"
        case .disableExecutablePageProtection: return "Disable Executable Page Protection"
        case .debugger:                       return "Debugger"
        case .photosLibrary:                  return "Photos Library"
        // App Groups
        case .appGroups:                      return "App Groups"
        // iCloud
        case .iCloudContainers:               return "iCloud Containers"
        case .iCloudServices:                 return "iCloud Services"
        case .iCloudKeyValueStore:            return "iCloud Key-Value Store"
        case .iCloudContainerEnvironment:     return "iCloud Environment"
        // Push
        case .pushNotifications:              return "Push Notifications"
        // Apple Pay
        case .applePay:                       return "Apple Pay"
        // Associated Domains
        case .associatedDomains:              return "Associated Domains"
        // Keychain
        case .keychainAccessGroups:           return "Keychain Access Groups"
        case .keychainSharing:                return "Keychain Sharing"
        // Network Extensions
        case .networkExtensions:              return "Network Extensions"
        case .personalVPN:                    return "Personal VPN"
        case .dnsProxy:                       return "DNS Proxy"
        case .contentFilterProvider:          return "Content Filter Provider"
        // Multicast / Networking
        case .multicast:                      return "Multicast"
        case .hotspotConfiguration:           return "Hotspot Configuration"
        case .hotspotHelper:                  return "Hotspot Helper"
        // NFC
        case .nfcTagReaderSession:            return "NFC Tag Reader"
        // Health
        case .healthKit:                      return "HealthKit"
        case .healthKitCapabilities:          return "HealthKit Capabilities"
        case .healthRecords:                  return "Health Records"
        // HomeKit
        case .homeKit:                        return "HomeKit"
        // ClassKit
        case .classKit:                       return "ClassKit"
        // AutoFill
        case .autoFillCredentialProvider:     return "AutoFill Credential Provider"
        // Siri
        case .siri:                           return "Siri"
        // Maps
        case .maps:                           return "Maps"
        // Game Center
        case .gameCenter:                     return "Game Center"
        // Wallet
        case .wallet:                         return "Wallet / Passes"
        // Sign In with Apple
        case .signInWithApple:                return "Sign In with Apple"
        // Fonts
        case .fontInstallation:               return "Font Installation"
        // System Extensions
        case .systemExtension:                return "System Extension"
        case .driverKitFamilies:              return "DriverKit Families"
        // Notifications
        case .communicationNotifications:     return "Communication Notifications"
        case .timeSensitiveNotifications:     return "Time-Sensitive Notifications"
        // App Attest
        case .appAttest:                      return "App Attest"
        // Memory
        case .extendedVirtualAddressing:      return "Extended Virtual Addressing"
        case .increasedMemoryLimit:           return "Increased Memory Limit"
        // Background
        case .backgroundModes:                return "Background Modes"
        // Audio
        case .interAppAudio:                  return "Inter-App Audio"
        // Shared with You
        case .sharedWithYou:                  return "Shared with You"
        // WeatherKit
        case .weatherKit:                     return "WeatherKit"
        // Media
        case .mediaDeviceDiscovery:           return "Media Device Discovery"
        // Group Activities
        case .groupActivities:                return "Group Activities"
        // App Intents
        case .appIntents:                     return "App Intents"
        }
    }

    /// Default starting value when adding this key in the UI.
    public var defaultValue: String {
        switch self {
        // Sandbox — booleans
        case .appSandbox:                     return "YES"
        case .sandboxNetworkClient:           return "YES"
        case .sandboxNetworkServer:           return "YES"
        case .sandboxFilesReadOnly:           return "YES"
        case .sandboxFilesReadWrite:          return "YES"
        case .sandboxFilesDownloadsReadOnly:  return "YES"
        case .sandboxFilesDownloadsReadWrite: return "YES"
        case .sandboxFilesPicturesReadOnly:   return "YES"
        case .sandboxFilesPicturesReadWrite:  return "YES"
        case .sandboxFilesMusicReadOnly:      return "YES"
        case .sandboxFilesMusicReadWrite:     return "YES"
        case .sandboxFilesMoviesReadOnly:     return "YES"
        case .sandboxFilesMoviesReadWrite:    return "YES"
        case .sandboxAllFiles:                return "YES"
        case .sandboxUSBAccess:               return "YES"
        case .sandboxSerialAccess:            return "YES"
        case .sandboxPrinting:                return "YES"
        case .sandboxCamera:                  return "YES"
        case .sandboxMicrophone:              return "YES"
        case .sandboxBluetooth:               return "YES"
        case .sandboxAddressBook:             return "YES"
        case .sandboxCalendars:               return "YES"
        case .sandboxLocation:                return "YES"
        case .sandboxAppleEvents:             return "YES"
        case .sandboxBookmarksDocument:       return "YES"
        case .sandboxBookmarksApp:            return "YES"
        // Hardened Runtime — booleans
        case .allowJIT:                       return "YES"
        case .allowUnsignedExecutableMemory:  return "YES"
        case .allowDYLDEnvironmentVariables:  return "YES"
        case .disableLibraryValidation:       return "YES"
        case .disableExecutablePageProtection: return "YES"
        case .debugger:                       return "YES"
        case .photosLibrary:                  return "YES"
        // App Groups — array of strings
        case .appGroups:                      return ""
        // iCloud
        case .iCloudContainers:               return ""
        case .iCloudServices:                 return ""
        case .iCloudKeyValueStore:            return "$(TeamIdentifierPrefix)$(CFBundleIdentifier)"
        case .iCloudContainerEnvironment:     return "Development"
        // Push
        case .pushNotifications:              return "development"
        // Apple Pay — array of merchant IDs
        case .applePay:                       return ""
        // Associated Domains — array
        case .associatedDomains:              return ""
        // Keychain — array
        case .keychainAccessGroups:           return ""
        case .keychainSharing:                return ""
        // Network Extensions — array
        case .networkExtensions:              return ""
        case .personalVPN:                    return ""
        case .dnsProxy:                       return "YES"
        case .contentFilterProvider:          return "YES"
        // Multicast / Networking
        case .multicast:                      return "YES"
        case .hotspotConfiguration:           return "YES"
        case .hotspotHelper:                  return "YES"
        // NFC — array
        case .nfcTagReaderSession:            return ""
        // Health
        case .healthKit:                      return "YES"
        case .healthKitCapabilities:          return ""
        case .healthRecords:                  return "YES"
        // HomeKit
        case .homeKit:                        return "YES"
        // ClassKit
        case .classKit:                       return "development"
        // AutoFill
        case .autoFillCredentialProvider:     return "YES"
        // Siri
        case .siri:                           return "YES"
        // Maps
        case .maps:                           return "YES"
        // Game Center
        case .gameCenter:                     return "YES"
        // Wallet — array
        case .wallet:                         return ""
        // Sign In with Apple — array
        case .signInWithApple:                return ""
        // Fonts
        case .fontInstallation:               return "YES"
        // System Extensions
        case .systemExtension:                return "YES"
        case .driverKitFamilies:              return ""
        // Notifications
        case .communicationNotifications:     return "YES"
        case .timeSensitiveNotifications:     return "YES"
        // App Attest
        case .appAttest:                      return "production"
        // Memory
        case .extendedVirtualAddressing:      return "YES"
        case .increasedMemoryLimit:           return "YES"
        // Background
        case .backgroundModes:                return ""
        // Audio
        case .interAppAudio:                  return "YES"
        // Shared with You
        case .sharedWithYou:                  return "YES"
        // WeatherKit
        case .weatherKit:                     return "YES"
        // Media
        case .mediaDeviceDiscovery:           return "YES"
        // Group Activities
        case .groupActivities:               return "YES"
        // App Intents
        case .appIntents:                     return "YES"
        }
    }

    /// Category grouping for UI display.
    public var category: Category {
        switch self {
        case .appSandbox, .sandboxNetworkClient, .sandboxNetworkServer,
             .sandboxFilesReadOnly, .sandboxFilesReadWrite,
             .sandboxFilesDownloadsReadOnly, .sandboxFilesDownloadsReadWrite,
             .sandboxFilesPicturesReadOnly, .sandboxFilesPicturesReadWrite,
             .sandboxFilesMusicReadOnly, .sandboxFilesMusicReadWrite,
             .sandboxFilesMoviesReadOnly, .sandboxFilesMoviesReadWrite,
             .sandboxAllFiles, .sandboxUSBAccess, .sandboxSerialAccess,
             .sandboxPrinting, .sandboxCamera, .sandboxMicrophone,
             .sandboxBluetooth, .sandboxAddressBook, .sandboxCalendars,
             .sandboxLocation, .sandboxAppleEvents,
             .sandboxBookmarksDocument, .sandboxBookmarksApp:
            return .sandbox
        case .allowJIT, .allowUnsignedExecutableMemory,
             .allowDYLDEnvironmentVariables, .disableLibraryValidation,
             .disableExecutablePageProtection, .debugger,
             .photosLibrary:
            return .hardenedRuntime
        case .appGroups:
            return .appGroups
        case .iCloudContainers, .iCloudServices, .iCloudKeyValueStore,
             .iCloudContainerEnvironment:
            return .iCloud
        case .pushNotifications:
            return .push
        case .applePay:
            return .applePay
        case .associatedDomains:
            return .associatedDomains
        case .keychainAccessGroups, .keychainSharing:
            return .keychain
        case .networkExtensions, .personalVPN, .dnsProxy, .contentFilterProvider:
            return .networkExtensions
        case .multicast, .hotspotConfiguration, .hotspotHelper:
            return .networking
        case .nfcTagReaderSession:
            return .nfc
        case .healthKit, .healthKitCapabilities, .healthRecords:
            return .health
        case .homeKit:
            return .homeKit
        case .classKit:
            return .classKit
        case .autoFillCredentialProvider:
            return .autofill
        case .siri:
            return .siri
        case .maps:
            return .maps
        case .gameCenter:
            return .gameCenter
        case .wallet:
            return .wallet
        case .signInWithApple:
            return .signInWithApple
        case .fontInstallation:
            return .fonts
        case .systemExtension, .driverKitFamilies:
            return .systemExtensions
        case .communicationNotifications, .timeSensitiveNotifications:
            return .notifications
        case .appAttest:
            return .appAttest
        case .extendedVirtualAddressing, .increasedMemoryLimit:
            return .memory
        case .backgroundModes:
            return .background
        case .interAppAudio:
            return .audio
        case .sharedWithYou:
            return .sharedWithYou
        case .weatherKit:
            return .weatherKit
        case .mediaDeviceDiscovery:
            return .media
        case .groupActivities:
            return .groupActivities
        case .appIntents:
            return .appIntents
        }
    }

    public enum Category: String, CaseIterable, Sendable {
        case sandbox           = "App Sandbox"
        case hardenedRuntime   = "Hardened Runtime"
        case appGroups         = "App Groups"
        case iCloud            = "iCloud"
        case push              = "Push Notifications"
        case applePay          = "Apple Pay"
        case associatedDomains = "Associated Domains"
        case keychain          = "Keychain"
        case networkExtensions = "Network Extensions"
        case networking        = "Networking"
        case nfc               = "NFC"
        case health            = "HealthKit"
        case homeKit           = "HomeKit"
        case classKit          = "ClassKit"
        case autofill          = "AutoFill"
        case siri              = "Siri"
        case maps              = "Maps"
        case gameCenter        = "Game Center"
        case wallet            = "Wallet"
        case signInWithApple   = "Sign In with Apple"
        case fonts             = "Fonts"
        case systemExtensions  = "System Extensions"
        case notifications     = "Notifications"
        case appAttest         = "App Attest"
        case memory            = "Memory"
        case background        = "Background Tasks"
        case audio             = "Audio"
        case sharedWithYou     = "Shared with You"
        case weatherKit        = "WeatherKit"
        case media             = "Media"
        case groupActivities   = "Group Activities"
        case appIntents        = "App Intents"
    }

    /// All keys in a given category, preserving declaration order.
    public static func keys(in category: Category) -> [EntitlementKey] {
        allCases.filter { $0.category == category }
    }
}

import JavaScriptKit

extension EntitlementKey: ConvertibleToJSValue, ConstructibleFromJSValue {
    
    public var jsValue: JSValue { rawValue.jsValue }
    
    public static func construct(from value: JSValue) -> EntitlementKey? {
        guard let string = value.string else { return nil }
        return .init(rawValue: string)
    }
}
