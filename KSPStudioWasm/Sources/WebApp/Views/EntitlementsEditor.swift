//
//  EntitlementsEditor.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit


@View
struct EntitlementsEditor {
    @State var data: Entitlements
    @State var newKey: String = ""
    @State var newValue: String = ""
    @State var stringKeya = true
    @Environment(#Key(\.colorScheme)) var colorScheme

    var sortedKeys: [String] {
        []
    }
    
    var body: some View {
        
        #Table(layout: .auto) {
            thead {
                tr {
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) {
                        BoolField(fieldLabel: "Key - (raw)", value: $stringKeya)
                    }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) { "" }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) { "Value" }
                }
            }
            ForEach(data.sortedArray, key: \.key) { (key, value) in
                #TableRow {
                    #TableCell(width: .w_1_4) {
                        label(key: key)
                    }
                    
                    #TableCell(width: .auto) { ColonSymbol() }
                    #TableCell {
                        EValueInputRow(value: value) {
                            data.removeValue(forKey: key)
                        }
                    }
                }
                
            }
            // Add new entry row
            #TableRow {
                #TableCell {
                    input(
                        .type(.text),
                        .class("w-full border border-gray-200 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 rounded px-3 py-1.5 text-sm"),
                        .placeholder("Key")
                    )
                    .bindValue($newKey)
                }
                #TableCell { span(.class("text-gray-400")) { "=" } }
                #TableCell {
                    HStack {
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
                                    data[k] = .init(entry: .string(.init(storage: newKey)))
                                    newKey = ""
                                    newValue = ""
                                }
                            }
                    }
                }
            }
        }
//        KeyPicker(keys: Self.entitlementsPickableKeys, onPick: { rawValue in
//            if data[rawValue] == nil, let defaultValue = EntitlementKey(rawValue: rawValue)?.defaultValue {
//                data[rawValue] = .init(entry: .string(.init(storage: defaultValue)))
//            }
//        })
        KeyPicker(
            label: BorderedLabel(
                text: "+ known key",
                font: .init(color: .gray_900),
                border: .init(color: colorScheme == .dark ? .gray_600 : .gray_900, width: 2),
                bg_color: .green_500
            ),
            keys: Self.entitlementsPickableKeys
        ) { rawValue in
            if data[rawValue] == nil, let defaultValue = InfoPlistKey(rawValue: rawValue)?.defaultValue {
                data[rawValue] = .init(entry: .string(.init(storage: defaultValue)))
            }
        }
    }
    
    func label(key: String) -> some View {
        if let knownKey = InfoPlistKey(rawValue: key) {
            BorderedLabel(
                text: stringKeya ? knownKey.label : key,
                width: .w_full,
                border: .init(color: colorScheme == .dark ? .gray_600 : .gray_300),
                bg_color: colorScheme == .dark ? .green_900 : .green_50
            )
        } else {
            BorderedLabel(
                text: key,
                border: .init(color: colorScheme == .dark ? .gray_600 : .gray_300),
                bg_color: colorScheme == .dark ? .yellow_900 : .yellow_50
            )
        }
    }

}

extension EntitlementsEditor {
    private static let entitlementsPickableKeys: [PickableKey] = EntitlementKey.allCases.map {
        PickableKey(category: $0.category.rawValue, label: $0.label, rawValue: $0.rawValue)
    }
}


extension InfoPlistEditor {
    
    
    
}

@View
struct EValueInputRow {
    
    @State var value: Entitlements.Value
    
    let onDelete: ()->Void
    
    var body: some View {
        
        HStack {
            switch value.entry {
                case .string(let single):
                    StringView(value: single)
                case .bool(let bool):
                    BoolView(value: bool)
                case .array(let array):
                    ArrayView(value: array)
                case .dict(let dict):
                    DictionaryView(value: dict)
            }
            button(.class("text-red-500 hover:text-red-700 text-sm cursor-pointer px-2")) { "✕" }
                .onClick { _ in
                    onDelete()
                }
        }
    }
    
}

extension EValueInputRow {
    
    
    
    @View
    struct StringView {
        
        @State var value: Entitlements.StringValue
        
        var body: some View {
            ValueInput(text: #Binding(value.storage)) // full width when switched to .single
        }
    }
    
    @View
    struct BoolView {
        
        @State var value: Entitlements.BoolValue
        
        var body: some View {
            BoolField(fieldLabel: "", value: #Binding(value.storage))
        }
    }
    
    @View
    struct ArrayView {
        
        @State var value: Entitlements.ArrayValue
        
        var body: some View {
            #Border(radius: .sm) {
                VStack(spacing: .sm) {
                    ForEach(value.storage, key: \.id) { item in
                        EValueInputRow(value: item)  {
                            value.storage.removeAll { v in
                                v.id == item.id
                            }
                        }
                    }
//                    Button(title: "Add", html: .defaultRed) {
//                        value.storage.append(.init(entry: .string(.init(storage: ""))))
//                    }
                    Button(label: BorderedLabel(text: "+", border: .init(color: .red_500), bg_color: .red_50)) {
                        value.storage.append(.init(entry: .string(.init(storage: ""))))
                    }
                }
            }
        }
    }
    
    @View
    struct DictionaryView {
        
        @State var value: Entitlements.DictionaryValue
        
        var body: some View {
            #Border(radius: .sm) {
                #Table(layout: .auto) {
                    header()
                    ForEach(sortedData(), key: \.0) { (k,v) in
                        #TableRow {
                            #TableCell(width: .w_1_4) {
                                ValueInput(text: .init(get: {
                                    k
                                }, set: { new in
                                    value.storage.removeValue(forKey: k)
                                    value.storage[new] = v
                                }))
                            }
                            
                            #TableCell(width: .shrink) { ColonSymbol() }
                            #TableCell {
                                EValueInputRow(value: v) {
                                    value.storage.removeValue(forKey: k)
                                }
                            }
                        }
                        
                    }
                    
                }
            }
        }
        
        func header() -> some View {
            thead {
                tr {
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) { "Key" }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) { "" }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700")) { "Value" }
                }
            }
        }
        
        func sortedData() -> [(String , Entitlements.Value)] {
            value.storage.sorted(by: {$0.key < $1.key})
        }
    }
    
    
}


