//
//  ValueInputRow.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit


@View
struct ValueInputRow {
    
    @State var value: InfoPlist.Value
    
    let onDelete: ()->Void
    
    var body: some View {
        
        HStack {
            switch value.entry {
                case .string(let value):
                    StringView(value: value)
                case .bool(let value):
                    BoolView(value: value)
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

extension ValueInputRow {
    
    
    
    @View
    struct StringView {
        
        @State var value: InfoPlist.StringValue
        
        var body: some View {
            ValueInput(text: #Binding(value.storage)) // full width when switched to .single
        }
    }
    
    @View
    struct BoolView {
        
        @State var value: InfoPlist.BoolValue
        
        var body: some View {
            BoolField(fieldLabel: "", value: #Binding(value.storage))// full width when switched to .single
        }
    }
    
    @View
    struct ArrayView {
        
        @State var value: InfoPlist.ArrayValue
        
        var body: some View {
            #Border(radius: .sm) {
                VStack(spacing: .sm) {
                    ForEach(value.storage, key: \.id) { item in
                        ValueInputRow(value: item)  {
                            value.storage.removeAll { v in
                                v.id == item.id
                            }
                        }
                    }
//                    Button(title: "Add", html: .defaultRed) {
//                        value.storage.append(.init(entry: .string(.init(storage: ""))))
//                    }
                    Button {
                        BorderedLabel(text: "+", border: .init(color: .green_100), bg_color: .green_50)
                    } onClick: {
                        value.storage.append(.init(entry: .string(.init(storage: ""))))
                    }

                }
            }
        }
    }
    
    @View
    struct DictionaryView {
        
        @State var value: InfoPlist.DictionaryValue
        
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
                                ValueInputRow(value: v) {
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
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 border-b border-gray-200")) { "Key" }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 border-b border-gray-200")) { "" }
                    th(.class("px-3 py-2 text-left text-sm font-semibold text-gray-700 border-b border-gray-200")) { "Value" }
                }
            }
        }
        
        func sortedData() -> [(String , InfoPlist.Value)] {
            value.storage.sorted(by: {$0.key < $1.key})
        }
    }
    
    
}

@View
struct ValueInput {
    
    @Binding var text: String
    let width: TextWidthStyle
    let border: CSSBorderInfo
    @State var temp: String
    @FocusState var focus
    
    init(text: Binding<String>, width: TextWidthStyle = .w_full, border: CSSBorderInfo = .init(color: .gray_300)) {
        self._text = text
        self.temp = text.wrappedValue
        self.width = width
        self.border = border
    }
    
    var body: some View {
        input(
            .type(.text),
            .class("\(width.rawValue) \(border.css) dark:bg-gray-900 dark:text-gray-100 px-3 py-1.5 text-sm"),
            .value(text)
        )
        .bindValue($temp)
        .focused($focus)
        .onChange(of: focus, { old, new in
            if text != temp {
                text = temp
            }
        })
//        .onInput { event in
//            temp = event.targetValue ?? ""
//        }
    }
    
}


