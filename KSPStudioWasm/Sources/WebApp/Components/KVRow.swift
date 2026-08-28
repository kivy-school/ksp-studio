import ElementaryUI
import JavaScriptKit

@View
struct KVRow {
    var dictKey: String
    @Binding var dict: [String: String]

    var body: some View {
        div(.class("flex items-center gap-2")) {
            input(
                .type(.text),
                .class("w-1/3 border border-gray-300 dark:border-gray-600 rounded px-3 py-1.5 text-sm bg-gray-50 dark:bg-gray-800 dark:text-gray-300"),
                .value(dictKey),
                .custom(name: "disabled", value: "")
            )
            span(.class("text-gray-400 dark:text-gray-500")) { "=" }
            input(
                .type(.text),
                .class("flex-1 border border-gray-300 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm"),
                .value(dict[dictKey] ?? "")
            )
            .onInput { event in
                dict[dictKey] = event.targetValue ?? ""
            }
            button(.class("text-red-500 hover:text-red-700 text-sm cursor-pointer px-2")) { "✕" }
                .onClick { _ in
                    dict.removeValue(forKey: dictKey)
                }
        }
    }
}
