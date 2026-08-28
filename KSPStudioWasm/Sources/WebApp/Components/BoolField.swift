import ElementaryUI
import JavaScriptKit

@View
struct BoolField {
    var fieldLabel: String
    @Binding var value: Bool

    var body: some View {
        div(.class("flex items-center gap-4 py-1")) {
            label(.class("w-40 text-sm font-medium text-gray-600 dark:text-gray-400 text-right")) { fieldLabel }
            input(.type(.checkbox), .class("h-4 w-4 text-indigo-600 rounded"))
                .bindChecked($value)
        }
    }
}
