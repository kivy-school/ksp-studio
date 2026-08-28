import ElementaryUI

/// Kivy's `Permissions` fetches known permission names from an API for a
/// picker (`PermissionsModal`); no such API is wired up here, so this is a
/// plain add/remove list, same simplification already used for
/// `ApplePermissionsTab`.
@View
struct AndroidPermissionsTab {
    var section: KivySchoolData.AndroidData

    var body: some View {
        SectionHeader(title: "Android Permissions", icon: "🛡️")
        ListEditor(fieldLabel: "Permissions", items: #Binding(section.permissions))
    }
}
