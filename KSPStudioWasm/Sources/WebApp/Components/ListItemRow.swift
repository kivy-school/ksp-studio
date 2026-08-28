import ElementaryUI
import JavaScriptKit

@View
struct ListItemRow {
    @Binding var value: String
    var onRemove: () -> Void

    var body: some View {
        div(.class("flex items-center gap-2")) {
            input(
                .type(.text),
                .class("flex-1 border border-gray-300 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm")
            )
            .bindValue($value)
            button(.class("text-red-500 hover:text-red-700 text-sm cursor-pointer px-2")) { "✕" }
                .onClick { _ in onRemove() }
        }
    }
}
