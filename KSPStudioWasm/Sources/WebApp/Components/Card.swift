import ElementaryUI
import JavaScriptKit

/// Generic rounded panel — the reference app's `RoundedBoxLayout` equivalent.
/// Use this instead of repeating the raw `bg-white dark:bg-gray-800
/// rounded-lg shadow p-6` class string inline.
@View
struct Card<Content: View> {
    var content: Content
    typealias Tag = HTMLTag.div

    init(@HTMLBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        div(.class("bg-white dark:bg-gray-800 rounded-lg shadow p-6")) {
            content
        }
    }
}
