//
//  InfoPlistKey.swift
//  PSProjectConfigWasm
//
//  Created by CodeBuilder on 04/03/2026.
//


import Foundation

/// All common Info.plist keys used in Xcode projects, grouped by category.
public enum InfoPlistKey: String, CaseIterable, Sendable {

    // MARK: - Core / Bundle Identity

    case bundleDevelopmentRegion          = "CFBundleDevelopmentRegion"
    case bundleDisplayName                = "CFBundleDisplayName"
    case bundleExecutable                 = "CFBundleExecutable"
    case bundleIdentifier                 = "CFBundleIdentifier"
    case bundleInfoDictionaryVersion      = "CFBundleInfoDictionaryVersion"
    case bundleName                       = "CFBundleName"
    case bundlePackageType                = "CFBundlePackageType"
    case bundleShortVersionString         = "CFBundleShortVersionString"
    case bundleVersion                    = "CFBundleVersion"
    case bundleSignature                  = "CFBundleSignature"
    case bundleIconFile                   = "CFBundleIconFile"
    case bundleIconName                   = "CFBundleIconName"
    case bundleIcons                      = "CFBundleIcons"
    case bundleURLTypes                   = "CFBundleURLTypes"
    case bundleDocumentTypes              = "CFBundleDocumentTypes"

    // MARK: - Launch / UI

    case launchStoryboardName             = "UILaunchStoryboardName"
    case mainStoryboardFile               = "UIMainStoryboardFile"
    case principalClass                   = "NSPrincipalClass"
    case mainNibFile                      = "NSMainNibFile"
    case requiresFullScreen               = "UIRequiresFullScreen"
    case statusBarHidden                  = "UIStatusBarHidden"
    case statusBarStyle                   = "UIStatusBarStyle"
    case viewControllerBasedStatusBar     = "UIViewControllerBasedStatusBarAppearance"
    case supportedInterfaceOrientations   = "UISupportedInterfaceOrientations"
    case supportedInterfaceOrientationsiPad = "UISupportedInterfaceOrientations~ipad"
    case userInterfaceStyle               = "UIUserInterfaceStyle"
    case supportsMultipleScenes           = "UIApplicationSupportsMultipleScenes"
    case applicationSceneManifest         = "UIApplicationSceneManifest"
    case backgroundModes                  = "UIBackgroundModes"
    case appFonts                         = "UIAppFonts"
    case whitePointAdaptivityStyle        = "UIWhitePointAdaptivityStyle"

    // MARK: - App Transport Security

    case appTransportSecurity             = "NSAppTransportSecurity"
    case allowsArbitraryLoads             = "NSAllowsArbitraryLoads"
    case allowsArbitraryLoadsForMedia     = "NSAllowsArbitraryLoadsForMedia"
    case allowsArbitraryLoadsInWebContent = "NSAllowsArbitraryLoadsInWebContent"
    case allowsLocalNetworking            = "NSAllowsLocalNetworking"

    // MARK: - Privacy / Usage Descriptions

    case privacyBluetoothAlwaysUsage      = "NSBluetoothAlwaysUsageDescription"
    case privacyBluetoothPeripheralUsage  = "NSBluetoothPeripheralUsageDescription"
    case privacyCalendarsUsage            = "NSCalendarsUsageDescription"
    case privacyCalendarsFullAccessUsage  = "NSCalendarsFullAccessUsageDescription"
    case privacyCalendarsWriteOnlyAccessUsage = "NSCalendarsWriteOnlyAccessUsageDescription"
    case privacyCameraUsage               = "NSCameraUsageDescription"
    case privacyContactsUsage             = "NSContactsUsageDescription"
    case privacyFaceIDUsage               = "NSFaceIDUsageDescription"
    case privacyFallDetectionUsage        = "NSFallDetectionUsageDescription"
    case privacyHealthClinicalHealthRecordsShareUsage = "NSHealthClinicalHealthRecordsShareUsageDescription"
    case privacyHealthShareUsage          = "NSHealthShareUsageDescription"
    case privacyHealthUpdateUsage         = "NSHealthUpdateUsageDescription"
    case privacyHomeKitUsage              = "NSHomeKitUsageDescription"
    case privacyLocationAlwaysUsage       = "NSLocationAlwaysUsageDescription"
    case privacyLocationAlwaysAndWhenInUseUsage = "NSLocationAlwaysAndWhenInUseUsageDescription"
    case privacyLocationUsage             = "NSLocationUsageDescription"
    case privacyLocationWhenInUseUsage    = "NSLocationWhenInUseUsageDescription"
    case privacyLocationTemporaryUsage    = "NSLocationTemporaryUsageDescriptionDictionary"
    case privacyMicrophoneUsage           = "NSMicrophoneUsageDescription"
    case privacyMotionUsage               = "NSMotionUsageDescription"
    case privacyNearbyInteractionUsage    = "NSNearbyInteractionUsageDescription"
    case privacyNFCReaderUsage            = "NFCReaderUsageDescription"
    case privacyPhotoLibraryUsage         = "NSPhotoLibraryUsageDescription"
    case privacyPhotoLibraryAddUsage      = "NSPhotoLibraryAddUsageDescription"
    case privacyRemindersUsage            = "NSRemindersUsageDescription"
    case privacyRemindersFullAccessUsage  = "NSRemindersFullAccessUsageDescription"
    case privacySensorKitUsage            = "NSSensorKitUsageDescription"
    case privacySiriUsage                 = "NSSiriUsageDescription"
    case privacySpeechRecognitionUsage    = "NSSpeechRecognitionUsageDescription"
    case privacyTrackingUsage             = "NSUserTrackingUsageDescription"
    case privacyVideoSubscriberAccountUsage = "NSVideoSubscriberAccountUsageDescription"
    case privacyWorldSensingUsage         = "NSWorldSensingUsageDescription"
    case privacyHandsTrackingUsage        = "NSHandsTrackingUsageDescription"
    case privacyIdentityUsage             = "NSIdentityUsageDescription"

    // MARK: - Privacy - macOS Specific

    case privacyAppleEventsUsage          = "NSAppleEventsUsageDescription"
    case privacySystemAdminUsage          = "NSSystemAdministrationUsageDescription"
    case privacyDesktopFolderUsage        = "NSDesktopFolderUsageDescription"
    case privacyDocumentsFolderUsage      = "NSDocumentsFolderUsageDescription"
    case privacyDownloadsFolderUsage      = "NSDownloadsFolderUsageDescription"
    case privacyNetworkVolumesUsage       = "NSNetworkVolumesUsageDescription"
    case privacyRemovableVolumesUsage     = "NSRemovableVolumesUsageDescription"
    case privacyFileProviderDomainUsage   = "NSFileProviderDomainUsageDescription"
    case privacyFileProviderPresenceUsage = "NSFileProviderPresenceUsageDescription"
    case privacySystemExtensionUsage      = "NSSystemExtensionUsageDescription"
    case privacyLocalNetworkUsage         = "NSLocalNetworkUsageDescription"

    // MARK: - Privacy - Photos / Media

    case privacyPhotoLibraryAdditions     = "PHPhotoLibraryPreventAutomaticLimitedAccessAlert"
    case privacyMediaLibraryUsage         = "NSAppleMusicUsageDescription"

    // MARK: - Networking

    case bonjourServices                  = "NSBonjourServices"
    case querySchemes                     = "LSApplicationQueriesSchemes"

    // MARK: - Files & Documents

    case exportedTypeDeclarations         = "UTExportedTypeDeclarations"
    case importedTypeDeclarations         = "UTImportedTypeDeclarations"
    case supportsDocumentBrowser          = "UISupportsDocumentBrowser"
    case fileSharingEnabled               = "UIFileSharingEnabled"
    case supportsOpeningDocumentsInPlace  = "LSSupportsOpeningDocumentsInPlace"

    // MARK: - Capabilities

    case applicationSupportsIndirectInputEvents = "UIApplicationSupportsIndirectInputEvents"
    case supportsLiveActivities           = "NSSupportsLiveActivities"
    case supportsLiveActivitiesFrequentUpdates = "NSSupportsLiveActivitiesFrequentUpdates"
    case supportsGameControllers          = "GCSupportedGameControllers"

    // MARK: - App Clips

    case appClipRequestEphemeralUserNotification = "NSAppClip"

    // MARK: - Extensions

    case extensionPointIdentifier         = "NSExtensionPointIdentifier"
    case extensionMainStoryboard          = "NSExtensionMainStoryboard"
    case extensionPrincipalClass          = "NSExtensionPrincipalClass"
    case extensionAttributes              = "NSExtensionAttributes"

    // MARK: - macOS Specific

    case applicationIsAgent               = "LSUIElement"
    case applicationCategory              = "LSApplicationCategoryType"
    case humanReadableCopyright           = "NSHumanReadableCopyright"
    case highResolutionCapable            = "NSHighResolutionCapable"
    case supportsAutomaticGraphicsSwitching = "NSSupportsAutomaticGraphicsSwitching"
    case appSandboxEnabled                = "com.apple.security.app-sandbox"
    case sparkleAutoUpdate                = "SUEnableAutomaticChecks"
    case sparkleFeedURL                   = "SUFeedURL"

    // MARK: - Minimum OS Versions

    case minimumOSVersion                 = "MinimumOSVersion"
    case lsMinimumSystemVersion           = "LSMinimumSystemVersion"

    // MARK: - Device Capabilities

    case requiredDeviceCapabilities       = "UIRequiredDeviceCapabilities"
    case deviceFamily                     = "UIDeviceFamily"

    // MARK: - Accessibility

    case accessibilitySupportsPurpose     = "UIAccessibilitySupportsAutoFill"

    // MARK: - Push Notifications

    case apsEnvironment                   = "aps-environment"
    case backgroundFetchInterval          = "UIApplicationBackgroundFetchInterval"
    case registeredForRemoteNotifications = "UIRemoteNotificationType"

    /// Human-readable label for this key.
    public var label: String {
        switch self {
        // Core
        case .bundleDevelopmentRegion:     return "Development Region"
        case .bundleDisplayName:           return "Display Name"
        case .bundleExecutable:            return "Executable"
        case .bundleIdentifier:            return "Bundle Identifier"
        case .bundleInfoDictionaryVersion: return "Info Dictionary Version"
        case .bundleName:                  return "Bundle Name"
        case .bundlePackageType:           return "Package Type"
        case .bundleShortVersionString:    return "Short Version"
        case .bundleVersion:               return "Build Number"
        case .bundleSignature:             return "Signature"
        case .bundleIconFile:              return "Icon File"
        case .bundleIconName:              return "Icon Name"
        case .bundleIcons:                 return "Icons"
        case .bundleURLTypes:              return "URL Types"
        case .bundleDocumentTypes:         return "Document Types"
        // Launch / UI
        case .launchStoryboardName:        return "Launch Storyboard"
        case .mainStoryboardFile:          return "Main Storyboard"
        case .principalClass:              return "Principal Class"
        case .mainNibFile:                 return "Main Nib File"
        case .requiresFullScreen:          return "Requires Full Screen"
        case .statusBarHidden:             return "Status Bar Hidden"
        case .statusBarStyle:              return "Status Bar Style"
        case .viewControllerBasedStatusBar: return "VC-Based Status Bar"
        case .supportedInterfaceOrientations: return "Orientations (iPhone)"
        case .supportedInterfaceOrientationsiPad: return "Orientations (iPad)"
        case .userInterfaceStyle:          return "Interface Style"
        case .supportsMultipleScenes:      return "Multiple Scenes"
        case .applicationSceneManifest:    return "Scene Manifest"
        case .backgroundModes:             return "Background Modes"
        case .appFonts:                    return "App Fonts"
        case .whitePointAdaptivityStyle:   return "White Point Adaptivity"
        // ATS
        case .appTransportSecurity:        return "App Transport Security"
        case .allowsArbitraryLoads:        return "Allows Arbitrary Loads"
        case .allowsArbitraryLoadsForMedia: return "Arbitrary Loads (Media)"
        case .allowsArbitraryLoadsInWebContent: return "Arbitrary Loads (Web)"
        case .allowsLocalNetworking:       return "Allows Local Networking"
        // Privacy
        case .privacyBluetoothAlwaysUsage: return "Bluetooth Always"
        case .privacyBluetoothPeripheralUsage: return "Bluetooth Peripheral"
        case .privacyCalendarsUsage:       return "Calendars"
        case .privacyCalendarsFullAccessUsage: return "Calendars Full Access"
        case .privacyCalendarsWriteOnlyAccessUsage: return "Calendars Write Only"
        case .privacyCameraUsage:          return "Camera"
        case .privacyContactsUsage:        return "Contacts"
        case .privacyFaceIDUsage:          return "Face ID"
        case .privacyFallDetectionUsage:   return "Fall Detection"
        case .privacyHealthClinicalHealthRecordsShareUsage: return "Health Records"
        case .privacyHealthShareUsage:     return "Health Share"
        case .privacyHealthUpdateUsage:    return "Health Update"
        case .privacyHomeKitUsage:         return "HomeKit"
        case .privacyLocationAlwaysUsage:  return "Location Always"
        case .privacyLocationAlwaysAndWhenInUseUsage: return "Location Always & When In Use"
        case .privacyLocationUsage:        return "Location"
        case .privacyLocationWhenInUseUsage: return "Location When In Use"
        case .privacyLocationTemporaryUsage: return "Location Temporary"
        case .privacyMicrophoneUsage:      return "Microphone"
        case .privacyMotionUsage:          return "Motion"
        case .privacyNearbyInteractionUsage: return "Nearby Interaction"
        case .privacyNFCReaderUsage:       return "NFC Reader"
        case .privacyPhotoLibraryUsage:    return "Photo Library"
        case .privacyPhotoLibraryAddUsage: return "Photo Library (Add)"
        case .privacyRemindersUsage:       return "Reminders"
        case .privacyRemindersFullAccessUsage: return "Reminders Full Access"
        case .privacySensorKitUsage:       return "SensorKit"
        case .privacySiriUsage:            return "Siri"
        case .privacySpeechRecognitionUsage: return "Speech Recognition"
        case .privacyTrackingUsage:        return "User Tracking"
        case .privacyVideoSubscriberAccountUsage: return "Video Subscriber"
        case .privacyWorldSensingUsage:    return "World Sensing"
        case .privacyHandsTrackingUsage:   return "Hands Tracking"
        case .privacyIdentityUsage:        return "Identity"
        // Privacy - macOS
        case .privacyAppleEventsUsage:     return "Apple Events"
        case .privacySystemAdminUsage:     return "System Administration"
        case .privacyDesktopFolderUsage:   return "Desktop Folder"
        case .privacyDocumentsFolderUsage: return "Documents Folder"
        case .privacyDownloadsFolderUsage: return "Downloads Folder"
        case .privacyNetworkVolumesUsage:  return "Network Volumes"
        case .privacyRemovableVolumesUsage: return "Removable Volumes"
        case .privacyFileProviderDomainUsage: return "File Provider Domain"
        case .privacyFileProviderPresenceUsage: return "File Provider Presence"
        case .privacySystemExtensionUsage: return "System Extension"
        case .privacyLocalNetworkUsage:    return "Local Network"
        // Photos / Media
        case .privacyPhotoLibraryAdditions: return "Photo Library Auto-Alert"
        case .privacyMediaLibraryUsage:    return "Apple Music / Media"
        // Networking
        case .bonjourServices:             return "Bonjour Services"
        case .querySchemes:                return "Query Schemes"
        // Files
        case .exportedTypeDeclarations:    return "Exported UTI Types"
        case .importedTypeDeclarations:    return "Imported UTI Types"
        case .supportsDocumentBrowser:     return "Document Browser"
        case .fileSharingEnabled:          return "File Sharing"
        case .supportsOpeningDocumentsInPlace: return "Open Documents In Place"
        // Capabilities
        case .applicationSupportsIndirectInputEvents: return "Indirect Input Events"
        case .supportsLiveActivities:      return "Live Activities"
        case .supportsLiveActivitiesFrequentUpdates: return "Live Activities Frequent Updates"
        case .supportsGameControllers:     return "Game Controllers"
        // App Clips
        case .appClipRequestEphemeralUserNotification: return "App Clip"
        // Extensions
        case .extensionPointIdentifier:    return "Extension Point"
        case .extensionMainStoryboard:     return "Extension Storyboard"
        case .extensionPrincipalClass:     return "Extension Principal Class"
        case .extensionAttributes:         return "Extension Attributes"
        // macOS
        case .applicationIsAgent:          return "Agent (LSUIElement)"
        case .applicationCategory:         return "App Category"
        case .humanReadableCopyright:      return "Copyright"
        case .highResolutionCapable:       return "High-Res Capable"
        case .supportsAutomaticGraphicsSwitching: return "Auto Graphics Switching"
        case .appSandboxEnabled:           return "App Sandbox"
        case .sparkleAutoUpdate:           return "Sparkle Auto-Update"
        case .sparkleFeedURL:              return "Sparkle Feed URL"
        // Min OS
        case .minimumOSVersion:            return "Minimum OS Version"
        case .lsMinimumSystemVersion:      return "Minimum macOS Version"
        // Device
        case .requiredDeviceCapabilities:  return "Required Capabilities"
        case .deviceFamily:                return "Device Family"
        // Accessibility
        case .accessibilitySupportsPurpose: return "AutoFill Support"
        // Push
        case .apsEnvironment:              return "APS Environment"
        case .backgroundFetchInterval:     return "Background Fetch Interval"
        case .registeredForRemoteNotifications: return "Remote Notification Type"
        }
    }

    /// Default starting value when adding this key in the UI.
    public var defaultValue: String {
        switch self {
        // Core / Bundle Identity
        case .bundleDevelopmentRegion:     return "en"
        case .bundleDisplayName:           return "$(PRODUCT_NAME)"
        case .bundleExecutable:            return "$(EXECUTABLE_NAME)"
        case .bundleIdentifier:            return "$(PRODUCT_BUNDLE_IDENTIFIER)"
        case .bundleInfoDictionaryVersion: return "6.0"
        case .bundleName:                  return "$(PRODUCT_NAME)"
        case .bundlePackageType:           return "$(PRODUCT_BUNDLE_PACKAGE_TYPE)"
        case .bundleShortVersionString:    return "1.0"
        case .bundleVersion:               return "1"
        case .bundleSignature:             return "????"
        case .bundleIconFile:              return ""
        case .bundleIconName:              return "AppIcon"
        case .bundleIcons:                 return ""
        case .bundleURLTypes:              return ""
        case .bundleDocumentTypes:         return ""
        // Launch / UI
        case .launchStoryboardName:        return "LaunchScreen"
        case .mainStoryboardFile:          return "Main"
        case .principalClass:              return "NSApplication"
        case .mainNibFile:                 return "MainMenu"
        case .requiresFullScreen:          return "YES"
        case .statusBarHidden:             return "NO"
        case .statusBarStyle:              return "UIStatusBarStyleDefault"
        case .viewControllerBasedStatusBar: return "YES"
        case .supportedInterfaceOrientations: return "UIInterfaceOrientationPortrait"
        case .supportedInterfaceOrientationsiPad: return "UIInterfaceOrientationPortrait"
        case .userInterfaceStyle:          return "Light"
        case .supportsMultipleScenes:      return "NO"
        case .applicationSceneManifest:    return ""
        case .backgroundModes:             return ""
        case .appFonts:                    return ""
        case .whitePointAdaptivityStyle:   return "UIWhitePointAdaptivityStyleStandard"
        // ATS
        case .appTransportSecurity:        return ""
        case .allowsArbitraryLoads:        return "NO"
        case .allowsArbitraryLoadsForMedia: return "NO"
        case .allowsArbitraryLoadsInWebContent: return "NO"
        case .allowsLocalNetworking:       return "NO"
        // Privacy
        case .privacyBluetoothAlwaysUsage: return "This app needs Bluetooth access"
        case .privacyBluetoothPeripheralUsage: return "This app needs Bluetooth peripheral access"
        case .privacyCalendarsUsage:       return "This app needs calendar access"
        case .privacyCalendarsFullAccessUsage: return "This app needs full calendar access"
        case .privacyCalendarsWriteOnlyAccessUsage: return "This app needs calendar write access"
        case .privacyCameraUsage:          return "This app needs camera access"
        case .privacyContactsUsage:        return "This app needs contacts access"
        case .privacyFaceIDUsage:          return "This app uses Face ID for authentication"
        case .privacyFallDetectionUsage:   return "This app needs fall detection access"
        case .privacyHealthClinicalHealthRecordsShareUsage: return "This app needs health records access"
        case .privacyHealthShareUsage:     return "This app needs health data read access"
        case .privacyHealthUpdateUsage:    return "This app needs health data write access"
        case .privacyHomeKitUsage:         return "This app needs HomeKit access"
        case .privacyLocationAlwaysUsage:  return "This app needs location access at all times"
        case .privacyLocationAlwaysAndWhenInUseUsage: return "This app needs location access at all times"
        case .privacyLocationUsage:        return "This app needs location access"
        case .privacyLocationWhenInUseUsage: return "This app needs location access while in use"
        case .privacyLocationTemporaryUsage: return "This app needs temporary location access"
        case .privacyMicrophoneUsage:      return "This app needs microphone access"
        case .privacyMotionUsage:          return "This app needs motion data access"
        case .privacyNearbyInteractionUsage: return "This app needs nearby interaction access"
        case .privacyNFCReaderUsage:       return "This app needs NFC access"
        case .privacyPhotoLibraryUsage:    return "This app needs photo library access"
        case .privacyPhotoLibraryAddUsage: return "This app needs to save photos"
        case .privacyRemindersUsage:       return "This app needs reminders access"
        case .privacyRemindersFullAccessUsage: return "This app needs full reminders access"
        case .privacySensorKitUsage:       return "This app needs sensor data access"
        case .privacySiriUsage:            return "This app needs Siri access"
        case .privacySpeechRecognitionUsage: return "This app needs speech recognition access"
        case .privacyTrackingUsage:        return "This app needs to track your activity"
        case .privacyVideoSubscriberAccountUsage: return "This app needs video subscriber access"
        case .privacyWorldSensingUsage:    return "This app needs world sensing access"
        case .privacyHandsTrackingUsage:   return "This app needs hand tracking access"
        case .privacyIdentityUsage:        return "This app needs identity verification access"
        // Privacy - macOS
        case .privacyAppleEventsUsage:     return "This app needs to send Apple Events"
        case .privacySystemAdminUsage:     return "This app needs admin privileges"
        case .privacyDesktopFolderUsage:   return "This app needs Desktop folder access"
        case .privacyDocumentsFolderUsage: return "This app needs Documents folder access"
        case .privacyDownloadsFolderUsage: return "This app needs Downloads folder access"
        case .privacyNetworkVolumesUsage:  return "This app needs network volume access"
        case .privacyRemovableVolumesUsage: return "This app needs removable volume access"
        case .privacyFileProviderDomainUsage: return "This app needs file provider access"
        case .privacyFileProviderPresenceUsage: return "This app needs file provider presence access"
        case .privacySystemExtensionUsage: return "This app needs system extension access"
        case .privacyLocalNetworkUsage:    return "This app needs local network access"
        // Photos / Media
        case .privacyPhotoLibraryAdditions: return "NO"
        case .privacyMediaLibraryUsage:    return "This app needs media library access"
        // Networking
        case .bonjourServices:             return ""
        case .querySchemes:                return ""
        // Files
        case .exportedTypeDeclarations:    return ""
        case .importedTypeDeclarations:    return ""
        case .supportsDocumentBrowser:     return "NO"
        case .fileSharingEnabled:          return "NO"
        case .supportsOpeningDocumentsInPlace: return "NO"
        // Capabilities
        case .applicationSupportsIndirectInputEvents: return "YES"
        case .supportsLiveActivities:      return "YES"
        case .supportsLiveActivitiesFrequentUpdates: return "NO"
        case .supportsGameControllers:     return ""
        // App Clips
        case .appClipRequestEphemeralUserNotification: return ""
        // Extensions
        case .extensionPointIdentifier:    return ""
        case .extensionMainStoryboard:     return "MainInterface"
        case .extensionPrincipalClass:     return ""
        case .extensionAttributes:         return ""
        // macOS
        case .applicationIsAgent:          return "NO"
        case .applicationCategory:         return "public.app-category.utilities"
        case .humanReadableCopyright:      return "Copyright © 2026. All rights reserved."
        case .highResolutionCapable:       return "YES"
        case .supportsAutomaticGraphicsSwitching: return "YES"
        case .appSandboxEnabled:           return "YES"
        case .sparkleAutoUpdate:           return "YES"
        case .sparkleFeedURL:              return "https://example.com/appcast.xml"
        // Min OS
        case .minimumOSVersion:            return "17.0"
        case .lsMinimumSystemVersion:      return "14.0"
        // Device
        case .requiredDeviceCapabilities:  return "arm64"
        case .deviceFamily:                return "1"
        // Accessibility
        case .accessibilitySupportsPurpose: return "YES"
        // Push
        case .apsEnvironment:              return "development"
        case .backgroundFetchInterval:     return "UIApplicationBackgroundFetchIntervalMinimum"
        case .registeredForRemoteNotifications: return ""
        }
    }

    /// Category grouping for UI display.
    public var category: Category {
        switch self {
        case .bundleDevelopmentRegion, .bundleDisplayName, .bundleExecutable,
             .bundleIdentifier, .bundleInfoDictionaryVersion, .bundleName,
             .bundlePackageType, .bundleShortVersionString, .bundleVersion,
             .bundleSignature, .bundleIconFile, .bundleIconName, .bundleIcons,
             .bundleURLTypes, .bundleDocumentTypes:
            return .bundle
        case .launchStoryboardName, .mainStoryboardFile, .principalClass,
             .mainNibFile, .requiresFullScreen, .statusBarHidden, .statusBarStyle,
             .viewControllerBasedStatusBar, .supportedInterfaceOrientations,
             .supportedInterfaceOrientationsiPad, .userInterfaceStyle,
             .supportsMultipleScenes, .applicationSceneManifest, .backgroundModes,
             .appFonts, .whitePointAdaptivityStyle:
            return .ui
        case .appTransportSecurity, .allowsArbitraryLoads,
             .allowsArbitraryLoadsForMedia, .allowsArbitraryLoadsInWebContent,
             .allowsLocalNetworking:
            return .ats
        case .privacyBluetoothAlwaysUsage, .privacyBluetoothPeripheralUsage,
             .privacyCalendarsUsage, .privacyCalendarsFullAccessUsage,
             .privacyCalendarsWriteOnlyAccessUsage,
             .privacyCameraUsage, .privacyContactsUsage, .privacyFaceIDUsage,
             .privacyFallDetectionUsage,
             .privacyHealthClinicalHealthRecordsShareUsage,
             .privacyHealthShareUsage, .privacyHealthUpdateUsage,
             .privacyHomeKitUsage, .privacyLocationAlwaysUsage,
             .privacyLocationAlwaysAndWhenInUseUsage, .privacyLocationUsage,
             .privacyLocationWhenInUseUsage, .privacyLocationTemporaryUsage,
             .privacyMicrophoneUsage, .privacyMotionUsage,
             .privacyNearbyInteractionUsage, .privacyNFCReaderUsage,
             .privacyPhotoLibraryUsage, .privacyPhotoLibraryAddUsage,
             .privacyRemindersUsage, .privacyRemindersFullAccessUsage,
             .privacySensorKitUsage, .privacySiriUsage,
             .privacySpeechRecognitionUsage, .privacyTrackingUsage,
             .privacyVideoSubscriberAccountUsage, .privacyWorldSensingUsage,
             .privacyHandsTrackingUsage, .privacyIdentityUsage,
             .privacyAppleEventsUsage, .privacySystemAdminUsage,
             .privacyDesktopFolderUsage, .privacyDocumentsFolderUsage,
             .privacyDownloadsFolderUsage, .privacyNetworkVolumesUsage,
             .privacyRemovableVolumesUsage, .privacyFileProviderDomainUsage,
             .privacyFileProviderPresenceUsage, .privacySystemExtensionUsage,
             .privacyLocalNetworkUsage, .privacyPhotoLibraryAdditions,
             .privacyMediaLibraryUsage:
            return .privacy
        case .bonjourServices, .querySchemes:
            return .networking
        case .exportedTypeDeclarations, .importedTypeDeclarations,
             .supportsDocumentBrowser,
             .fileSharingEnabled, .supportsOpeningDocumentsInPlace:
            return .files
        case .applicationSupportsIndirectInputEvents, .supportsLiveActivities,
             .supportsLiveActivitiesFrequentUpdates,
             .supportsGameControllers:
            return .capabilities
        case .appClipRequestEphemeralUserNotification:
            return .appClips
        case .extensionPointIdentifier, .extensionMainStoryboard,
             .extensionPrincipalClass, .extensionAttributes:
            return .extensions
        case .applicationIsAgent, .applicationCategory, .humanReadableCopyright,
             .highResolutionCapable, .supportsAutomaticGraphicsSwitching,
             .appSandboxEnabled, .sparkleAutoUpdate, .sparkleFeedURL:
            return .macOS
        case .minimumOSVersion, .lsMinimumSystemVersion:
            return .minOS
        case .requiredDeviceCapabilities, .deviceFamily:
            return .device
        case .accessibilitySupportsPurpose:
            return .accessibility
        case .apsEnvironment, .backgroundFetchInterval,
             .registeredForRemoteNotifications:
            return .push
        }
    }

    public enum Category: String, CaseIterable, Sendable {
        case bundle        = "Bundle Identity"
        case ui            = "Launch & UI"
        case ats           = "App Transport Security"
        case privacy       = "Privacy / Usage Descriptions"
        case networking    = "Networking"
        case files         = "Files & Documents"
        case capabilities  = "Capabilities"
        case appClips      = "App Clips"
        case extensions    = "Extensions"
        case macOS         = "macOS Specific"
        case minOS         = "Minimum OS Version"
        case device        = "Device Capabilities"
        case accessibility = "Accessibility"
        case push          = "Push Notifications"
    }

    /// All keys in a given category, preserving declaration order.
    public static func keys(in category: Category) -> [InfoPlistKey] {
        allCases.filter { $0.category == category }
    }
}


import JavaScriptKit

extension InfoPlistKey: ConvertibleToJSValue, ConstructibleFromJSValue {
    
    public var jsValue: JSValue { rawValue.jsValue }
    
    public static func construct(from value: JSValue) -> InfoPlistKey? {
        guard let string = value.string else { return nil }
        return .init(rawValue: string)
    }
}
