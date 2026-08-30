import ElementaryUI
import JavaScriptKit
import JavaScriptEventLoop

@main
struct App {
    static func main() {
        // Required for async/await with JSPromise to work
        JavaScriptEventLoop.installGlobalExecutor()

        // Nothing to read out of the URL: the server was started from the root
        // of the ksproject it edits, so `/api/project` already resolves to the
        // one target. The old build parsed a folder name out of `/project/:name`
        // because Vapor served many projects from a single directory.
        _ = JSObject.global.console.log("Wasm app started")

        let app = Application(ProjectConfigApp())
        app.mount(in: .body)
    }
}
