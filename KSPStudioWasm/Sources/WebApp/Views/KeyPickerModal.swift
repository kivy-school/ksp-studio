//
//  KeyPickerModal.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit

/// Reactive modal popup listing pickable keys grouped by category.
/// Shows when `isPresented` is true; calls `onPick` with the raw key string.
@View
struct KeyPickerModal {
    @Binding var isPresented: Bool
    var keys: [PickableKey]
    var onPick: (String) -> Void

    @State var searchText: String = ""

    var filteredKeys: [PickableKey] {
        guard !searchText.isEmpty else { return keys }
        let query = searchText.lowercased()
        return keys.filter {
            $0.label.lowercased().contains(query) || $0.rawValue.lowercased().contains(query)
        }
    }

    var uniqueCategories: [String] {
        var seen = Set<String>()
        return filteredKeys.compactMap { k in
            if seen.contains(k.category) { return nil }
            seen.insert(k.category)
            return k.category
        }
    }

    var body: some View {
        if isPresented {
            // Backdrop
            div(.class("fixed inset-0 z-50 flex items-center justify-center bg-black/40")) {
                div(.class("absolute inset-0")) { "" }
                    .onClick { _ in close() }

                // Modal card
                div(.class("relative bg-white dark:bg-gray-800 rounded-lg shadow-xl w-full max-w-lg max-h-[80vh] flex flex-col")) {
                    // Header
                    div(.class("flex items-center justify-between px-4 py-3")) {
                        h3(.class("text-sm font-semibold text-gray-800 dark:text-gray-100")) { "Select a Key" }
                        button(
                            .type(.button),
                            .class("text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 cursor-pointer")
                        ) { "✕" }
                        .onClick { _ in close() }
                    }
                    .border(.separator, edges: .bottom)

                    // Search filter
                    div(.class("px-4 py-2")) {
                        input(
                            .type(.text),
                            .class("w-full text-sm border border-gray-300 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-2 py-1 focus:ring-indigo-500 focus:border-indigo-500"),
                            .placeholder("Filter keys...")
                        )
                        .bindValue($searchText)
                    }
                    .border(.separator, edges: .bottom)

                    // Key list grouped by category
                    div(.class("overflow-y-auto flex-1 px-2 py-2")) {
                        if filteredKeys.isEmpty {
                            p(.class("text-sm text-gray-400 dark:text-gray-500 text-center py-4")) { "No matching keys" }
                        } else {
                            for category in uniqueCategories {
                                div {
                                    p(.class("text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider px-2 pt-2 pb-1")) { category }
                                    for key in filteredKeys where key.category == category {
                                        PickableKeyButton(key: key, onPick: { rawValue in
                                            onPick(rawValue)
                                            close()
                                        })
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onKeyDown { event in
                if event.key == "Escape" { close() }
            }
        }
    }

    func close() {
        searchText = ""
        isPresented = false
    }
}

/// Self-contained picker: renders a trigger button and manages the modal internally.
/// Drop in one view — no external `@State` needed.
@View
struct KeyPicker<Label: View> {
    //var label: String = "+ Pick Known Key"
    let label: Label
    var keys: [PickableKey]
    var onPick: (String) -> Void

    @State var showModal: Bool = false
    
    public typealias Tag = HTMLTag.button
    
    init(
        @HTMLBuilder label: ()->Label,
        keys: [PickableKey],
        onPick: @escaping (String) -> Void
    ) {
        self.label = label()
        self.keys = keys
        self.onPick = onPick
    }
    
    init(
        label: Label,
        keys: [PickableKey],
        onPick: @escaping (String) -> Void
    ) {
        self.label = label
        self.keys = keys
        self.onPick = onPick
    }
    
    init(
        label: Label,
        keys: [PickableKey],
        onPick: @escaping (String) -> Void
    ) where Label: StringProtocol {
        self.label = label
        self.keys = keys
        self.onPick = onPick
    }


    var body: some View {
//        button(
//            .type(.button),
//            .class("text-sm text-emerald-600 hover:text-emerald-800 font-medium cursor-pointer mt-1")
//        ) { label }
//        .onClick { _ in showModal = true }
        Button(label: label) {
            showModal = true
        }

        KeyPickerModal(
            isPresented: $showModal,
            keys: keys,
            onPick: onPick
        )
    }
}

/// Single pickable key row — extracted so each button gets its own click handler.
@View
struct PickableKeyButton {
    var key: PickableKey
    var onPick: (String) -> Void

    var body: some View {
        button(
            .type(.button),
            .class("w-full text-left px-3 py-1.5 text-sm hover:bg-indigo-50 dark:hover:bg-gray-700 rounded flex justify-between items-center cursor-pointer")
        ) {
            span(.class("text-gray-800 dark:text-gray-100")) { key.label }
            span(.class("text-gray-400 dark:text-gray-500 text-xs font-mono")) { key.rawValue }
        }
        .onClick { _ in onPick(key.rawValue) }
    }
}
