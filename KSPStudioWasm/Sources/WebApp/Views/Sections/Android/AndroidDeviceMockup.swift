import ElementaryUI

/// Android counterparts to `IOSHomeMockup`/`IOSPresplashMockup` — same
/// generic `PhoneMockup` frame and `Clock` (see `Clock.swift`), just
/// Android's wallpaper/dock assets (kivy's `AndroidPane`/`PresplashPane`,
/// which oddly reuse the iOS wallpaper/icons in the reference app; using the
/// Android-labeled assets here instead since both exist).
@View
struct AndroidHomeMockup {
    var iconDataURL: String

    var body: some View {
        PhoneMockup(background: .image("/device/androidwall2.jpg")) {
            span(.class("absolute top-3 left-4 text-white text-xs font-mono tracking-wide")) { Clock.shared.time }
            img(.src("/device/appbar.svg"), .class("absolute top-3 right-4 w-10 h-auto"))

            if !iconDataURL.isEmpty {
                img(
                    .src(iconDataURL),
                    .class("absolute top-14 left-4 w-11 h-11 rounded-xl object-cover shadow")
                )
            }

            div(.class("absolute bottom-8 inset-x-0 flex justify-center")) {
                div(.class("flex items-center gap-3 bg-black/25 backdrop-blur-md rounded-[1.75rem] px-3 py-2.5")) {
                    img(.src("/device/contacts.svg"), .class("w-8 h-8"))
                    img(.src("/device/messages.svg"), .class("w-8 h-8"))
                    img(.src("/device/camera.svg"), .class("w-8 h-8"))
                    img(.src("/device/photos.svg"), .class("w-8 h-8"))
                }
            }
        }
    }
}

@View
struct AndroidPresplashMockup {
    var presplashDataURL: String
    var backgroundColorHex: String

    var body: some View {
        PhoneMockup(background: .color(backgroundColorHex)) {
            if !presplashDataURL.isEmpty {
                div(.class("absolute inset-0 flex items-center justify-center p-10")) {
                    img(.src(presplashDataURL), .class("max-w-full max-h-full object-contain"))
                }
            }
        }
    }
}
