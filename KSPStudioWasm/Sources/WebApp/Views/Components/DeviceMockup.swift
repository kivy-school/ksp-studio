//
//  DeviceMockup.swift
//  KSProjectStudioWasm
//
//  A generic phone-frame preview, and the two iOS-specific mockups built on
//  it (home screen, presplash). Mirrors the reference app's `PreviewPane` /
//  `IOSPane` / `IPresplashPane` (kivy ksproject-studio,
//  View/EntrypointScreen/components/IOS/components/IMiscellaneous).
//
//  Plain `.class(...)` strings throughout. This was once believed to be
//  load-bearing — chaining ElementaryViews' `.frame`/`.cornerRadius`/`.shadow`
//  modifiers was tried and reverted on the theory that the extra
//  `_AttributedElement<...>` view-tree depth reintroduced an `elementary-ui`
//  mount/reconciliation crash. That theory was wrong: the crash was the wasm
//  shadow stack overflowing into the static data segment, fixed in
//  `Package.swift`'s linker settings (see `AndroidHomeTab.swift` for the full
//  account). View-tree depth is no longer a hazard here, so the modifiers can
//  be used if they read better — note that `.frame` now takes pixel values
//  and emits Tailwind arbitrary-value classes (`w-[240px]`), not the scale
//  tokens (`w-full`) these hand-written class strings use.
//
import ElementaryUI
import JavaScriptKit

enum PhoneMockupBackground {
    case image(String)
    case color(String)

    var styleString: String {
        switch self {
        case .image(let url):
            "background-image: url('\(url)'); background-size: cover; background-position: center;"
        case .color(let hex):
            "background-color: \(hex);"
        }
    }
}

/// Generic device-frame wrapper: rounded bezel, dynamic-island notch, home
/// indicator, and a background (image or solid color) behind `content`.
@View
struct PhoneMockup<Content: View> {
    var background: PhoneMockupBackground
    var content: Content

    typealias Tag = HTMLTag.div

    init(background: PhoneMockupBackground, @HTMLBuilder content: () -> Content) {
        self.background = background
        self.content = content()
    }

    var body: some View {
        div(
            .class("relative w-[240px] h-[490px] flex-shrink-0 rounded-[2.5rem] border-[8px] border-black overflow-hidden shadow-xl"),
            .style(background.styleString)
        ) {
            content

            // Dynamic island
            div(.class("absolute left-1/2 top-2 -translate-x-1/2 w-20 h-6 bg-black rounded-full")) { "" }

            // Home indicator
            div(.class("absolute left-1/2 bottom-2 -translate-x-1/2 w-24 h-1 bg-black/70 rounded-full")) { "" }
        }
    }
}

/// iOS home-screen preview: wallpaper, the clock (`Clock.shared.time` — see
/// `Clock.swift`), the picked app icon, and a dock of the reference app's
/// sample icons.
@View
struct IOSHomeMockup {
    var iconDataURL: String

    var body: some View {
        PhoneMockup(background: .image("/device/ioswall2.jpg")) {
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
                    img(.src("/device/icontacts.svg"), .class("w-8 h-8"))
                    img(.src("/device/imessages.svg"), .class("w-8 h-8"))
                    img(.src("/device/icamera.svg"), .class("w-8 h-8"))
                    img(.src("/device/iphotos.svg"), .class("w-8 h-8"))
                }
            }
        }
    }
}

/// iOS presplash preview: solid background color with the picked presplash
/// image centered on it.
@View
struct IOSPresplashMockup {
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
