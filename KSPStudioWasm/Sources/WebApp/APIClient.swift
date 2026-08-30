import JavaScriptKit
import JavaScriptEventLoop

/// Simple API client — uses native browser JSON (no Foundation encode/decode).
///
/// There is no project name in these URLs any more. The server is started from
/// the root of the ksproject it edits, so it already knows which
/// `pyproject.toml` is the target and hands its path back in the response —
/// see `ksp_studio/project.py`. The old `/api/project/:name` form came from
/// the Vapor server, which served many projects out of one directory.
enum APIClient {

    /// Fetch project JSON from GET /api/project → JSObject
    static func fetchProject() async throws -> JSObject {
        let resp = try await JSPromise(
            JSObject.global.fetch!("/api/project").object!
        )!.value
        let json = try await JSPromise(resp.object!.json!().object!)!.value
        guard let obj = json.object else {
            throw JSError(message: "Expected JSON object from /api/project")
        }
        return obj
    }

    /// Save project via POST /api/project/save
    static func saveProject(data: JSValue) async throws -> SaveResult {
        let body = JSObject.global.JSON.stringify(data)

        let options = JSObject()
        options.method = "POST".jsValue
        let hdrs = JSObject()
        hdrs["Content-Type"] = "application/json".jsValue
        options.headers = hdrs.jsValue
        options.body = body

        let resp = try await JSPromise(
            JSObject.global.fetch!("/api/project/save", options).object!
        )!.value
        let json = try await JSPromise(resp.object!.json!().object!)!.value
        let status = json.object?.status.string ?? ""
        let message = json.object?.message.string ?? ""
        return SaveResult(status: status, message: message)
    }
}

struct SaveResult {
    var status: String
    var message: String
}

/// Minimal JS error wrapper for async throws.
struct JSError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}
