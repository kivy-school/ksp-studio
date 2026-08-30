import ElementaryUI
import JavaScriptKit

/// Top-level view for the Android platform: Home / Permissions / Services /
/// Miscellaneous, matching kivy's `android.kv` `CTabHeader` exactly. Built on
/// `RootModel`/`KivySchoolData.AndroidData`, not the legacy `ProjectModel` —
/// see `RootModel.swift`.
@View
struct AndroidConfigView {
    var section: KivySchoolData.AndroidData
    @Binding var activeTab: AndroidTab

    var body: some View {
        div {
            div(.class("bg-white dark:bg-gray-800 rounded-lg shadow")) {
                AndroidTabBar(activeTab: $activeTab)

                div(.class("p-6 space-y-1 dark:text-gray-100")) {
                    switch activeTab {
                    case .home:
                        AndroidHomeTab(section: section)
                    case .permissions:
                        AndroidPermissionsTab(section: section)
                    case .services:
                        AndroidServicesTab(section: section)
                    case .miscellaneous:
                        AndroidMiscellaneousTab(section: section)
                    }
                }

                div(.class("px-6 pb-4 text-xs text-gray-400 dark:text-gray-500")) {
                    "Session only for now — Android config isn't wired up to a save/load endpoint yet."
                }
            }
        }
    }
}

@View
struct AndroidTabBar {
    @Binding var activeTab: AndroidTab

    var body: some View {
        div(.class("flex")) {
            for tab in AndroidTab.allCases {
                AndroidTabButton(tab: tab, isActive: activeTab == tab, onSelect: { activeTab = tab })
            }
        }
        .border(.separator, edges: .bottom)
    }
}

@View
struct AndroidTabButton {
    var tab: AndroidTab
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
