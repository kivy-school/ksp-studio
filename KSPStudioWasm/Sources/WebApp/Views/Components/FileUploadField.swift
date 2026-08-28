//
//  FileUploadField.swift
//  KSProjectStudioWasm
//
//  Mirrors the reference app's `FileUploader` + `ImagePreview` (kivy
//  ksproject-studio, View/components/FileUploader, View/components/ImagePreview).
//
import ElementaryUI
import ElementaryViews
import JavaScriptKit
import JavaScriptEventLoop

/// Reads a JS `File` object into a `data:` URL string via `FileReader`.
/// `FileReader` is callback-based, so this bridges it through `JSPromise`
/// rather than needing a raw `JSClosure` at every call site.
func readFileAsDataURL(_ file: JSValue) async -> String? {
    let promise = JSPromise { resolve in
        guard let reader = JSObject.global.FileReader.object?.new() else {
            resolve(.failure(.undefined))
            return
        }
        reader.onload = JSOneshotClosure { _ in
            resolve(.success(reader.result))
            return .undefined
        }.jsValue
        reader.onerror = JSOneshotClosure { _ in
            resolve(.failure(.undefined))
            return .undefined
        }.jsValue
        _ = reader.readAsDataURL!(file)
    }
    guard case .success(let value) = await promise.result else { return nil }
    return value.string
}

/// A heading + description + "Add file" control that opens the native file
/// picker and stores the picked image as a `data:` URL in `value`.
@View
struct FileUploadField {
    var title: String
    var description: String
    /// Must be unique on the page — used to associate the visible button
    /// (a `<label for=...>`) with the hidden `<input type=file>` it triggers.
    var inputID: String
    @Binding var value: String

    var body: some View {
        div(.class("space-y-2")) {
            div {
                p(.class("text-sm font-semibold text-gray-700 dark:text-gray-200")) { title }
                p(.class("text-xs text-gray-400 dark:text-gray-500")) { description }
            }

            input(
                .type(.file),
                .accept("image/*"),
                .id(inputID),
                .class("hidden")
            )
            .task {
                // Elementary's `.onInput` hands back a typed `InputEvent` whose
                // `rawEvent` isn't public, so for file inputs (where we need the
                // raw `target.files`) we wire a native listener directly instead.
                guard let inputEl = JSObject.global.document.getElementById(inputID).object else { return }
                let listener = JSClosure { args in
                    guard
                        let jsEvent = args.first?.object,
                        let target = jsEvent.target.object,
                        let file = target.files.object?[0].object
                    else { return .undefined }
                    Task {
                        if let dataURL = await readFileAsDataURL(file.jsValue) {
                            value = dataURL
                        }
                    }
                    return .undefined
                }
                _ = inputEl.addEventListener!("change", listener)
            }

            label(
                .for(inputID),
                .class("inline-flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded cursor-pointer")
            ) {
                span { "+" }
                span { "Add file" }
            }
        }
    }
}

/// Small bordered preview box for a picked image, with a remove control.
/// Mirrors the reference app's `ImagePreview`.
@View
struct ImagePreviewBox {
    @Binding var value: String
    var boxClass: String = "w-28 h-28"

    var body: some View {
        if !value.isEmpty {
            div(.class("relative \(boxClass) flex-shrink-0")) {
                img(
                    .src(value),
                    .class("w-full h-full object-contain rounded-lg border border-gray-200 dark:border-gray-700 bg-white")
                )
                button(.class("absolute -top-2 -right-2 w-5 h-5 flex items-center justify-center rounded-full bg-red-500 text-white text-xs leading-none cursor-pointer")) { "✕" }
                    .onClick { _ in value = "" }
            }
        }
    }
}
