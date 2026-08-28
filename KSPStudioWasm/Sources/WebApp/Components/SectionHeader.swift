import ElementaryUI
import JavaScriptKit

@View
struct SectionHeader {
    var title: String
    var icon: String

    var body: some View {
        div(.class("flex items-center gap-2 pt-4 pb-2")) {
            span { icon }
            h3(.class("text-lg font-semibold text-gray-800 dark:text-gray-100")) { title }
        }
    }
}
