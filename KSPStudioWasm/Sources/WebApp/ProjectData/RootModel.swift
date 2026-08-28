import Reactivity
import JavaScriptKit
import JavaScriptKitExtensions

/// New root model built directly on `PyProjectToml` (the real
/// `ksproject_utils.pyproject_toml` shape — see `KivySchoolData.swift`)
/// rather than the legacy flat bridge (`ProjectModel` in `ProjectData.swift`).
/// The legacy model is untouched and still powers the Python/Apple tabs —
/// this is a separate, additive path for new work (starting with Android)
/// built on the real schema instead of the old ad hoc one.
@Reactive
final class RootModel: ConvertibleToJSValue, ConstructibleFromJSValue, Codable {
    var path: String
    var pyProject: PyProjectToml

    /// Always non-nil (eagerly constructed below), so it can be passed
    /// straight down the view tree by reference — no optional-unwrapping,
    /// no `@Binding` plumbing at every level. Every holder shares the same
    /// object; mutating a field on it is visible everywhere else holding
    /// the reference, and `@Reactive` on `AndroidData` itself drives the
    /// UI refresh.
    var android: KivySchoolData.AndroidData {
        pyProject.tool.kivySchool!.android!
    }

    init(path: String? = nil, pyProject: PyProjectToml? = nil) {
        self.path = path ?? ""
        let toml = pyProject ?? .init()
        let schoolData = toml.tool.kivySchool ?? KivySchoolData()
        if schoolData.android == nil {
            schoolData.android = KivySchoolData.AndroidData()
        }
        toml.tool.kivySchool = schoolData
        self.pyProject = toml
    }

    static func construct(from value: JSValue) -> Self? {
        guard let obj = value.object else { return nil }
        return Self.init(path: obj.path, pyProject: obj.pyProject)
    }

    var jsValue: JSValue {
        let obj = JSObject()
        obj.path = path
        obj.pyProject = pyProject
        return obj.jsValue
    }

    enum CodingKeys: String, CodingKey {
        case path, pyProject
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.path = try c.decodeIfPresent(String.self, forKey: .path) ?? ""
        let toml = try c.decodeIfPresent(PyProjectToml.self, forKey: .pyProject) ?? .init()
        let schoolData = toml.tool.kivySchool ?? KivySchoolData()
        if schoolData.android == nil {
            schoolData.android = KivySchoolData.AndroidData()
        }
        toml.tool.kivySchool = schoolData
        self.pyProject = toml
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(path, forKey: .path)
        try c.encode(pyProject, forKey: .pyProject)
    }
}
