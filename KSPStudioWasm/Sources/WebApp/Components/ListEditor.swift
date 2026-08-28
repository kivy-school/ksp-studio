import ElementaryUI
import JavaScriptKit

/// Add/remove editor for a `[String]` — used for dependency lists, backends,
/// permissions, etc. See `ListItemRow` for a single row.
@View
struct ListEditor {
    var fieldLabel: String
    @Binding var items: [String]
    @State var newItem: String = ""

    var body: some View {
        div(.class("py-2")) {
            label(.class("text-sm font-medium text-gray-600 dark:text-gray-400")) { fieldLabel }
            div(.class("mt-1 space-y-1")) {
                for i in items.indices {
                    ListItemRow(value: $items[i], onRemove: { items.remove(at: i) })
                }
                // Add new row
                div(.class("flex items-center gap-2")) {
                    input(
                        .type(.text),
                        .class("flex-1 border border-gray-200 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm"),
                        .placeholder("Add \(fieldLabel.lowercased())...")
                    )
                    .bindValue($newItem)
                    button(.class("text-green-600 hover:text-green-800 text-sm font-medium cursor-pointer px-2")) { "+ Add" }
                        .onClick { _ in
                            var trimmed = newItem
                            while trimmed.first?.isWhitespace == true { trimmed.removeFirst() }
                            while trimmed.last?.isWhitespace == true { trimmed.removeLast() }
                            if !trimmed.isEmpty {
                                items.append(trimmed)
                                newItem = ""
                            }
                        }
                }
            }
        }
    }
}
