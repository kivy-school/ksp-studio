//
//  CustomKeyValueRow.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit


@View
struct CustomKeyValueRow {
    var dictKey: String
    //@Binding var dict: [String: JSValue]
    var data: InfoPlist.Value

    let onDelete: ()->Void
    @Environment(#Key(\.colorScheme)) var colorScheme

    var body: some View {
        #TableRow {
            #TableCell {
                BorderedLabel(
                    text: dictKey,
                    font: .init(),
                    border: .init(color: colorScheme == .dark ? .gray_600 : .gray_300),
                    bg_color: colorScheme == .dark ? .yellow_900 : .yellow_50
                )
            }
            #TableCell { ColonSymbol() }
            #TableCell { ValueInputRow(value: data) { onDelete() } }
        }
    }
}
