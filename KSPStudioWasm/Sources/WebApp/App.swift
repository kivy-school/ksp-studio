import ElementaryUI
import JavaScriptKit
import JavaScriptEventLoop

@main
struct App {
    static func main() {
        // Required for async/await with JSPromise to work
        JavaScriptEventLoop.installGlobalExecutor()
        
        // Extract project folder name from URL path: /project/:name
        let pathname = JSObject.global.location.pathname.string ?? ""
        let parts = pathname.split(separator: "/")
        let folderName = parts.count >= 2 && parts[0] == "project" ? String(parts[1]) : ""
        
        _ = JSObject.global.console.log("Wasm app started, pathname: \(pathname), folderName: \(folderName)")

        let app = Application(ProjectConfigApp(folderName: folderName))
        app.mount(in: .body)
    }
}
