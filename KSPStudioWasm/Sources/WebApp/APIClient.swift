import JavaScriptKit
import JavaScriptEventLoop

/// Simple API client — uses native browser JSON (no Foundation encode/decode).
enum APIClient {

    /// Fetch project JSON from GET /api/project/:name → JSObject
    static func fetchProject(folderName: String) async throws -> JSObject {
        let resp = try await JSPromise(
            JSObject.global.fetch!("/api/project/\(folderName)").object!
        )!.value
        let json = try await JSPromise(resp.object!.json!().object!)!.value
        guard let obj = json.object else {
            throw JSError(message: "Expected JSON object from /api/project/\(folderName)")
        }
        return obj
    }

    /// Save project via POST /api/project/:name/save
    static func saveProject(folderName: String, data: JSValue) async throws -> SaveResult {
        let body = JSObject.global.JSON.stringify(data)

        let options = JSObject()
        options.method = "POST".jsValue
        let hdrs = JSObject()
        hdrs["Content-Type"] = "application/json".jsValue
        options.headers = hdrs.jsValue
        options.body = body

        let resp = try await JSPromise(
            JSObject.global.fetch!("/api/project/\(folderName)/save", options).object!
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
