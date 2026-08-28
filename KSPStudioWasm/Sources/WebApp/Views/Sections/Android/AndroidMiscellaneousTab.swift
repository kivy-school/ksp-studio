import ElementaryUI
import ElementaryViews
import JavaScriptKit

/// Mirrors kivy's Android `miscellaneous.kv`: icon upload + preview, presplash
/// upload + color + preview on the left, live device mockups on the right —
/// same shape as `IOSMiscellaneousTab`, reusing the same `Card`/
/// `FileUploadField`/`ImagePreviewBox` components.
@View
struct AndroidMiscellaneousTab {
    var section: KivySchoolData.AndroidData

    var body: some View {
        TwoColumnLayout {
            VStack(spacing: .md) {
                Card {
                    HStack(alignment: .top, spacing: .md) {
                        div(.class("flex-1")) {
                            FileUploadField(
                                title: "Android app icon",
                                description: "Square image, used as the home-screen icon.",
                                inputID: "android-icon-uploader",
                                value: Binding(
                                    get: { section.icon ?? "" },
                                    set: { section.icon = $0.isEmpty ? nil : $0 }
                                )
                            )
                        }
                        ImagePreviewBox(value: Binding(
                            get: { section.icon ?? "" },
                            set: { section.icon = $0.isEmpty ? nil : $0 }
                        ))
                    }
                }
                Card {
                    HStack(alignment: .top, spacing: .md) {
                        div(.class("flex-1 space-y-3")) {
                            FileUploadField(
                                title: "Android presplash",
                                description: "Shown while the app launches.",
                                inputID: "android-presplash-uploader",
                                value: Binding(
                                    get: { section.presplash ?? "" },
                                    set: { section.presplash = $0.isEmpty ? nil : $0 }
                                )
                            )
                            FormField(fieldLabel: "Presplash color", value: #Binding(section.presplashColor), placeholder: "#FFFFFF")
                        }
                        ImagePreviewBox(
                            value: Binding(
                                get: { section.presplash ?? "" },
                                set: { section.presplash = $0.isEmpty ? nil : $0 }
                            ),
                            boxClass: "w-36 h-36"
                        )
                    }
                }
            }
        } trailing: {
            div(.class("flex flex-row flex-wrap items-start justify-center gap-6")) {
                AndroidHomeMockup(iconDataURL: section.icon ?? "")
                AndroidPresplashMockup(
                    presplashDataURL: section.presplash ?? "",
                    backgroundColorHex: section.presplashColor.isEmpty ? "#FFFFFF" : section.presplashColor
                )
            }
        }
    }
}
