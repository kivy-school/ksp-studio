import ElementaryUI
import JavaScriptKit

/// Add/remove editor for a `[String: String]` — used for scripts, sources,
/// swift packages, etc. See `KVRow` for a single row.
@View
struct KeyValueEditor {
    @Binding var dict: [String: String]
    @State var newKey: String = ""
    @State var newValue: String = ""

    var sortedKeys: [String] {
        dict.keys.sorted()
    }

    var body: some View {
        div(.class("py-2 space-y-1")) {
            for key in sortedKeys {
                KVRow(dictKey: key, dict: $dict)
            }
            // Add new entry
            div(.class("flex items-center gap-2")) {
                input(
                    .type(.text),
                    .class("w-1/3 border border-gray-200 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm"),
                    .placeholder("Key")
                )
                .bindValue($newKey)
                span(.class("text-gray-400 dark:text-gray-500")) { "=" }
                input(
                    .type(.text),
                    .class("flex-1 border border-gray-200 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm"),
                    .placeholder("Value")
                )
                .bindValue($newValue)
                button(.class("text-green-600 hover:text-green-800 text-sm font-medium cursor-pointer px-2")) { "+ Add" }
                    .onClick { _ in
                        var k = newKey
                        while k.first?.isWhitespace == true { k.removeFirst() }
                        while k.last?.isWhitespace == true { k.removeLast() }
                        if !k.isEmpty {
                            dict[k] = newValue
                            newKey = ""
                            newValue = ""
                        }
                    }
            }
        }
    }
}
