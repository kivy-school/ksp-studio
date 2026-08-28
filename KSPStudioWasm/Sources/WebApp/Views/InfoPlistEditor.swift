//
//  InfoPlistEditor.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit


@View
struct InfoPlistEditor {
    @State var data: InfoPlist
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
                        ValueInputRow(value: value) {
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
//                        Button {
//                            BorderedLabel(text: "+", border: .init(color: .green_500), bg_color: .green_50)
//                        } onClick: {
//                            var k = newKey
//                            while k.first?.isWhitespace == true { k.removeFirst() }
//                            while k.last?.isWhitespace == true { k.removeLast() }
//                            if !k.isEmpty {
//                                data[k] = .init(entry: .string(.init(storage: newKey)))
//                                newKey = ""
//                                newValue = ""
//                            }
//                        }

//                        button(.class("text-green-600 hover:text-green-800 text-sm font-medium cursor-pointer px-2")) { "+ Add" }
//                            .onClick { _ in
//                                var k = newKey
//                                while k.first?.isWhitespace == true { k.removeFirst() }
//                                while k.last?.isWhitespace == true { k.removeLast() }
//                                if !k.isEmpty {
//                                    data[k] = .init(entry: .string(.init(storage: newKey)))
//                                    newKey = ""
//                                    newValue = ""
//                                }
//                            }
                    }
                }
            }
        }
        HStack {
            KeyPicker(
                label: BorderedLabel(
                    text: "+ known key",
                    font: .init(color: .gray_900),
                    border: .init(color: colorScheme == .dark ? .gray_600 : .gray_900, width: 2),
                    bg_color: .green_500
                ),
                keys: Self.infoPlistPickableKeys
            ) { rawValue in
                if data[rawValue] == nil, let defaultValue = InfoPlistKey(rawValue: rawValue)?.defaultValue {
                    data[rawValue] = .init(entry: .string(.init(storage: defaultValue)))
                }
            }
            BorderedLabel(
                text: "+ custom key",
                font: .init(color: .gray_900),
                border: .init(color: colorScheme == .dark ? .gray_600 : .gray_900),
                bg_color: .yellow_200
            )._button {
                data["qwerty"] = .init(entry: .string(.init(storage: "xyz")))
            }
        }
    
//        KeyPicker(keys: Self.infoPlistPickableKeys, onPick: { rawValue in
//            if data[rawValue] == nil, let defaultValue = InfoPlistKey(rawValue: rawValue)?.defaultValue {
//                data[rawValue] = .init(entry: .string(.init(storage: defaultValue)))
//            }
//        })
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

extension InfoPlistEditor {
    private static let infoPlistPickableKeys: [PickableKey] = InfoPlistKey.allCases.map {
        PickableKey(category: $0.category.rawValue, label: $0.label, rawValue: $0.rawValue)
    }
}


extension InfoPlistEditor {
    
    
    
}
