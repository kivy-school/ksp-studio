//
//  TestSequencerModal.swift
//  PSProjectConfigWasm
//
import ElementaryUI
import Reactivity
import JavaScriptKit
import Foundation

// MARK: - Environment Keys

extension EnvironmentValues {
    @Entry var stepColor: String = "red"
}

// MARK: - Sequencer Popup Window

/// Content view that gets mounted inside the popup window
@View
struct SequencerPopupContent {
    
    var body: some View {
        //div(.class("bg-gray-900 min-h-screen p-4 flex flex-col gap-4")) {
            #VStack {
            SequencerBox(data: .init())
                .environment(#Key(\.stepColor), "red")
            SequencerBox(data: .init())
                .environment(#Key(\.stepColor), "yellow")
            }
        //}
    }
}

/// Manages opening/closing a popup window with the sequencer
class SequencerPopupManager {
    private var popupWindow: JSValue = .undefined
    
    static let shared = SequencerPopupManager()
    
    func open() {
        // If already open and not closed, focus it
        if popupWindow != .undefined && popupWindow != .null {
            if let closed = popupWindow.closed.boolean, !closed {
                _ = popupWindow.focus()
                return
            }
        }
        
        // Open new popup window
        let features = "width=900,height=500,menubar=no,toolbar=no,location=no,status=no,resizable=yes"
        popupWindow = JSObject.global.window.open("", "StepSequencer", features)
        
        guard popupWindow != .null, popupWindow != .undefined,
              let win = popupWindow.object else { return }
        
        // Write basic HTML structure
        let doc = win.document.object!
        _ = doc.open!()
        _ = doc.write!("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Step Sequencer</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="margin:0; background:#111827;">
            <div id="sequencer-app"></div>
        </body>
        </html>
        """)
        _ = doc.close!()
        
        // Copy stylesheets from parent window into popup
        let parentDoc = JSObject.global.document.object!
        let parentStyles = parentDoc.querySelectorAll!("link[rel='stylesheet'], style")
        if let stylesObj = parentStyles.object {
            let length = Int(stylesObj.length.number ?? 0)
            for i in 0..<length {
                if let node = stylesObj[i].object {
                    let cloned = node.cloneNode!(true)
                    _ = doc.head.object!.appendChild!(cloned)
                }
            }
        }
        
        // Mount ElementaryUI app into the popup's #sequencer-app div
        if let appDiv = doc.getElementById!("sequencer-app").object {
            let app = Application(SequencerPopupContent())
            // Keep mounted app alive — cleanup happens when popup window closes
            _ = app._mount(in: appDiv)
        }
    }
    
    func close() {

        if popupWindow != .undefined && popupWindow != .null {
            _ = popupWindow.close()
        }
        popupWindow = .undefined
    }
}


@View struct SequencerBox {
    
    var data: SequencerData
    
    @State var lastX: Int?
    @State var lastY: Int?
    @State var lastStep: SequencerData.Step?
    @State var lastIndex: Int?
    @State var isDrawing = false
    @State var lastState = false
    
    var body: some View {
        #Border {
            div(.id("sequencer-grid")) {
                #VStack(spacing: .xs) {
                    ForEach(data.bars, key: \.id) { bar in
                        BarView(data: bar)
                    }
                }
            }
            
//            .onMouseDown { event in
//                isDrawing = true
//                lastStep = nil
//                if let (idx, step) = getStepFromEvent(event) {
//                    step.state.toggle()
//                    lastStep = step
//                    lastIndex = idx
//                    lastState = step.state
//                }
//            }
//            .onMouseMove { event in
//                guard isDrawing else { return }
//                if let (idx, step) = getStepFromEvent(event), lastIndex != idx {
//                    if step.state != lastState {
//                        step.state = lastState
//                    }
//                    lastIndex = idx
//                    lastStep = step
//                }
//            }
//            .onMouseUp { _ in
//                isDrawing = false
//                lastStep = nil
//            }
        }
    }
    
    func getStepFromEvent(_ event: MouseEvent) -> (Int,SequencerData.Step)? {
        let document = JSObject.global.document.object!
        guard let el = document.getElementById!("sequencer-grid").object else { return nil }
        guard let rect = el.getBoundingClientRect!().object else { return nil }
        
        let x = event.clientX - rect.left.number!
        let y = event.clientY - rect.top.number!
        let w = rect.width.number!
        let h = rect.height.number!
        
        let rows = data.bars.count
        let cols = data.bars.first?.steps.count ?? 16
        
        let indexX = Int(x / w * Double(cols))
        let indexY = Int(y / h * Double(rows))
        
        guard indexX >= 0, indexX < cols, indexY >= 0, indexY < rows else { return nil }
        let indexXY = (indexY * 16) + indexX
        return (indexXY, data.bars[indexY].steps[indexX])
    }
}


extension SequencerBox {
    @View struct BarView {
        var data: SequencerData.Bar
        
        var body: some View {
            #HStack(spacing: .xs) {
                ForEach(data.steps, key: \.id) { step in
                    StepView(data: step)
                }
            }
        }
    }
    
    @View struct StepView {
        @Environment(#Key(\.stepColor)) var color
        
        var data: SequencerData.Step
        
        var body: some View {
            div(
                .class(data.state
                    ? "flex-1 aspect-square rounded-sm cursor-pointer bg-\(color)-500"// hover:bg-red-400"
                    : "flex-1 aspect-square rounded-sm cursor-pointer bg-\(color)-900"// hover:bg-red-800"
                )
            ) { "" }
            
                 .onClick { _ in
                     data.state.toggle()
                 }
        }
    }
}

extension SequencerBox {
    @Reactive
    class SequencerData: Identifiable {
        
        let id: Int = UUID().hashValue
        
        var bars: [Bar]
        
        init(bars: [Bar]) {
            self.bars = bars
        }
        
        init() {
            self.bars = (0..<4).map({ _ in
                .init()
            })
        }
    }
}

extension SequencerBox.SequencerData {
    @Reactive
    class Bar: Identifiable {
        
        let id: Int = UUID().hashValue
        var steps: [Step]
        
        init(steps: [Step]) {
            self.steps = steps
        }
        
        init() {
            self.steps = (0..<16).map({ idx in
                .init(id: idx)
            })
        }
    }
    
    @Reactive
    class Step: Identifiable {
        
        let id: Int
        var state: Bool = false
        
        init(id: Int, state: Bool = false) {
            self.id = id
            self.state = state
        }
    }
}
