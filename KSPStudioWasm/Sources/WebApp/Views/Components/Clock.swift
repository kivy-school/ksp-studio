import Reactivity
import JavaScriptKit

/// Single shared ticking clock — every mockup reads from here instead of
/// each spinning up its own `.task` loop. One task, started once in
/// `init()`, tied to nothing's lifecycle but the app's.
@Reactive
final class Clock {
    static let shared = Clock()

    private(set) var time: String = currentTimeHHMM()

    private init() {
        Task {
            while true {
                time = currentTimeHHMM()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}

/// No Foundation `Date`/`DateFormatter` in this target (see `APIClient.swift`) —
/// read the clock straight from JS `Date` instead.
func currentTimeHHMM() -> String {
    let date = JSObject.global.Date.object!.new()
    let hours = Int(date.getHours!().number ?? 0)
    let minutes = Int(date.getMinutes!().number ?? 0)
    func pad(_ n: Int) -> String { n < 10 ? "0\(n)" : "\(n)" }
    return "\(pad(hours)):\(pad(minutes))"
}
