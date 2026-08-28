//
//  IOSMiscellaneousTab.swift
//  KSProjectStudioWasm
//
//  Icon + presplash upload with a live device preview, mirroring kivy's
//  IMiscellaneous (View/EntrypointScreen/components/IOS/components/IMiscellaneous).
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit

@View
struct IOSMiscellaneousTab {
    var section: PSProjectSection

    var body: some View {
        TwoColumnLayout {
            VStack(spacing: .md) {
                Card {
                    HStack(alignment: .top, spacing: .md) {
                        div(.class("flex-1")) {
                            FileUploadField(
                                title: "iOS app icon",
                                description: "Square image, used as the home-screen icon.",
                                inputID: "ios-icon-uploader",
                                value: #Binding(section.icon)
                            )
                        }
                        ImagePreviewBox(value: #Binding(section.icon))
                    }
                }

                Card {
                    HStack(alignment: .top, spacing: .md) {
                        div(.class("flex-1 space-y-3")) {
                            // A third level of VStack nesting here (VStack > HStack > VStack)
                            // triggers a "recursive expansion of macro 'VStack'" compiler
                            // error in ElementaryViews' macro implementation — plain div instead.
                            FileUploadField(
                                title: "iOS presplash",
                                description: "Shown while the app launches.",
                                inputID: "ios-presplash-uploader",
                                value: #Binding(section.presplash)
                            )
                            FormField(
                                fieldLabel: "Presplash color",
                                value: #Binding(section.presplashColor),
                                placeholder: "#FFFFFF"
                            )
                        }
                        ImagePreviewBox(value: #Binding(section.presplash), boxClass: "w-36 h-36")
                    }
                }
            }
        } trailing: {
            // Live device previews, side by side (matches kivy's horizontal
            // BoxLayout in imiscellaneous.kv). Not using HStack here — its
            // hardcoded `w-full` fights this row's sibling (the `flex-1`
            // left column) for space, squeezing it down.
            div(.class("flex flex-row flex-wrap items-start justify-center gap-6")) {
                IOSHomeMockup(iconDataURL: section.icon)
                IOSPresplashMockup(
                    presplashDataURL: section.presplash,
                    backgroundColorHex: section.presplashColor.isEmpty ? "#FFFFFF" : section.presplashColor
                )
            }
        }
    }
}
