import ElementaryUI
import JavaScriptKit

/// A `FormField` wrapped in its own `Card`, with an underlined (Carbon-style)
/// input instead of a boxed one — matches the reference app's Android/iOS
/// "Home" screens, where each field is its own card in a grid (see
/// `research/studio-pics/Screenshot 2026-08-26 at 20.02.43.png`). Drop
/// several of these in a `grid grid-cols-1 md:grid-cols-2 gap-4` container
/// to reproduce that layout.
@View
struct CardTextField {
    var fieldLabel: String
    @Binding var value: String
    var helperText: String? = nil
    var placeholder: String? = nil

    var body: some View {
        Card {
            div(.class("space-y-2")) {
                label(.class("block text-sm font-semibold text-gray-800 dark:text-gray-100")) { fieldLabel }
                input(
                    .type(.text),
                    .class("w-full bg-gray-50 dark:bg-gray-900/60 border-0 border-b-2 border-gray-300 dark:border-gray-600 focus:border-indigo-500 focus:outline-none px-2 py-2 text-sm text-gray-900 dark:text-gray-100 rounded-t"),
                    .placeholder(placeholder ?? "")
                )
                .bindValue($value)
                if let helperText {
                    p(.class("text-xs text-gray-400 dark:text-gray-500")) { helperText }
                }
            }
        }
    }
}
