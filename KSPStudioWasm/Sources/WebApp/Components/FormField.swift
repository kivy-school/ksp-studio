import ElementaryUI
import JavaScriptKit

/// Label-above-input field, matching the reference app's Carbon-style text
/// input (label on top, input below, optional helper text underneath) —
/// e.g. kivy's `CTextInputLayout` / `CTextInputLabel` / `CTextInputHelperText`.
@View
struct FormField {
    var fieldLabel: String
    @Binding var value: String
    var helperText: String? = nil
    var placeholder: String? = nil

    var body: some View {
        div(.class("py-2 max-w-md")) {
            label(.class("block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5")) { fieldLabel }
            input(
                .type(.text),
                .class("w-full border border-gray-300 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent"),
                .placeholder(placeholder ?? "")
            )
            .bindValue($value)
            if let helperText {
                p(.class("mt-1.5 text-xs text-gray-400 dark:text-gray-500")) { helperText }
            }
        }
    }
}
