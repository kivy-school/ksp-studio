//
//  KnownKeyValueRow.swift
//  PSProjectConfigWasm
//
//  Created by CodeBuilder on 05/03/2026.
//


import ElementaryUI
import ElementaryViews
import JavaScriptKit

@View
struct KnownKeyValueRow {
    let key: InfoPlistKey
    let rawKey: Bool
    //@Binding var dict: [String: JSValue]
    var data: InfoPlist.Value

    let onDelete: () -> Void
    @Environment(#Key(\.colorScheme)) var colorScheme

    var body: some View {
        #TableRow {
            #TableCell {
                BorderedLabel(
                    text: key,
                    border: .init(color: colorScheme == .dark ? .gray_600 : .gray_300),
                    bg_color: colorScheme == .dark ? .yellow_900 : .yellow_50
                )
            }
//                if rawKey {
//                    #TableCell {
//                        BorderedLabel(text: key.label, font: .init(), width: .w_1_3, border: .init(color: .gray_300), bg_color: .green_50)
//                    }
//                } else {
//                    #TableCell {
//                        BorderedLabel(text: key, font: .init(), border: .init(color: .gray_300), bg_color: .green_50)
//                    }
//                }
            
            #TableCell { ColonSymbol() }
            #TableCell { ValueInputRow(value: data) { onDelete() } }
        }
    }
}
