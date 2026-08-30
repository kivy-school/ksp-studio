import ElementaryUI
import ElementaryViews
import JavaScriptKit

/// Mirrors kivy's `home.kv`: a left grid of package/API/SDK/NDK fields and a
/// right column of arch checkboxes, side by side with a divider — see
/// `research/studio-pics/Screenshot 2026-08-26 at 20.02.43.png`.
///
/// Fields bind to `Int?`/`String?` model properties via the small
/// `Binding<String>` helpers below (nil-collapsing at the call site) rather
/// than components declaring their own `Binding<Optional<_>>` properties.
///
/// The right column also carries kivy's tool-path settings (`Toggle` +
/// conditional path field, gated on `nil`) in `AndroidPathSettings` below —
/// a sibling of `AndroidArchPicker`, not nested inside it (they aren't arch
/// settings): sdk, ndk, java and global-tools paths, plus the `global_tools`
/// switch the last of those hangs off.
///
/// This file previously carried a long warning that no structural variant of
/// these fields could exceed 2 simultaneous `Toggle`+conditional-field
/// instances without tripping "a memory-corruption bug in `elementary-ui`'s
/// reconciler" (varying WASM traps: out-of-bounds, unreachable, hard hangs).
/// That diagnosis was wrong, and the ceiling is gone. The traps were the wasm
/// shadow stack overflowing into the static data segment and corrupting type
/// metadata — the crash then surfaced far away, inside
/// `swift_getTypeByMangledName`, pointing at whichever view happened to
/// resolve a type next. It reproduced only in debug builds (`npm run dev`),
/// whose larger frames exhaust the stack sooner, which is what made it look
/// like a per-component capacity limit. The fix is in `Package.swift`'s
/// linker settings (`stack-size` + `--stack-first`); 4 of these fields were
/// verified rendering and toggling cleanly afterwards. Add fields here as
/// needed and size the layout for readability, not to dodge a crash.
///
/// Uses `HStack`/`Grid` for layout rather than hand-written
/// `div(.class("flex flex-row ..."))`/`div(.class("grid grid-cols-..."))`.
/// These were the `#HStack`/`#Grid` freestanding macros; they are now view
/// types in `ElementaryViews/Layout/Stack/Stacks.swift`, rendering the same
/// `div` with the same classes, because the macros could not nest inside
/// themselves.
@View
struct AndroidHomeTab {
    var section: KivySchoolData.AndroidData

    var body: some View {
        HStack(alignment: .top, spacing: .lg) {
            Grid(columns: .two) {
                CardTextField(
                    fieldLabel: "Package name",
                    value: #Binding(section.packageName),
                    helperText: "e.g. com.kivyschool.yourapp",
                    placeholder: "org.example.myapp"
                )
                CardTextField(
                    fieldLabel: "Minimum api version",
                    value: intBinding(\.minApi, on: section),
                    helperText: "recommended: 24",
                    placeholder: "24"
                )
                CardTextField(
                    fieldLabel: "Maximum api version",
                    value: intBinding(\.api, on: section),
                    helperText: "recommended: 36",
                    placeholder: "36"
                )
                CardTextField(
                    fieldLabel: "Android sdk version",
                    value: optionalStringBinding(\.sdk, on: section),
                    helperText: "recommended: 36",
                    placeholder: "36"
                )
                CardTextField(
                    fieldLabel: "Android ndk version",
                    value: optionalStringBinding(\.ndk, on: section),
                    helperText: "recommended: 28c",
                    placeholder: "28c"
                )
                CardTextField(
                    fieldLabel: "Android ndk api version",
                    value: intBinding(\.ndkApi, on: section),
                    helperText: "recommended: = min api = 24",
                    placeholder: "24"
                )
            }
            .attributes(.class("flex-1 min-w-0"))

            Divider(orientation: .vertical)

            div(.class("w-full lg:w-80 flex-shrink-0")) {
                VStack(spacing: .lg) {
                    AndroidArchPicker(section: section)
                    AndroidPathSettings(section: section)
                }
            }
        }
    }
}

/// Builds a `Binding<String>` over an `Int?` property — empty/non-numeric
/// text clears the value, matching the reference app's `int(self.text) if
/// self.text.isdigit() else None`.
func intBinding(
    _ keyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, Int?>,
    on section: KivySchoolData.AndroidData
) -> Binding<String> {
    Binding(
        get: { section[keyPath: keyPath].map(String.init) ?? "" },
        set: { section[keyPath: keyPath] = Int($0) }
    )
}

/// Builds a `Binding<String>` over a `String?` property — empty text clears
/// the value back to `nil`.
func optionalStringBinding(
    _ keyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, String?>,
    on section: KivySchoolData.AndroidData
) -> Binding<String> {
    Binding(
        get: { section[keyPath: keyPath] ?? "" },
        set: { section[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
    )
}

/// Shared Tailwind classes for the underlined path-input fields below —
/// pulled out as a plain constant (not a function) so the 4 near-identical
/// `input(...)` calls in `ToggleGatedPathField` don't hand-duplicate the class
/// string, without wrapping UI construction itself in a function.
private let pathInputClass = "w-full bg-gray-50 dark:bg-gray-900/60 border-0 border-b-2 border-gray-300 dark:border-gray-600 focus:border-indigo-500 focus:outline-none px-2 py-2 text-sm text-gray-900 dark:text-gray-100 rounded"

@View
struct AndroidArchPicker {
    var section: KivySchoolData.AndroidData

    var body: some View {
        VStack(spacing: .sm) {
            SectionHeader(title: "Android archs", icon: "🧩")
            p(.class("text-xs text-gray-400 dark:text-gray-500 -mt-2 mb-2")) { "Select x86_64 for emulator." }
            ArchCheckboxRow(section: section, arch: .arm64_v8a, label: "arm64-v8a")
            ArchCheckboxRow(section: section, arch: .x86_64, label: "x86_64")
        }
    }
}

/// `Toggle` is already the reusable unit for on/off state (see
/// `ElementaryViews/Toggle.swift`); the 4 path fields below are built via
/// `ToggleGatedPathField`. Split out as its own sibling struct because these
/// are path settings, not arch settings — `AndroidArchPicker` isn't where they
/// belong. (This split was once also needed to dodge the old `#VStack` macro's
/// inability to nest inside itself; `VStack` is a view type now and nests
/// freely, so the grouping here is purely about what these fields *are*.)
/// Each field's toggle state is presence-of-path (`nil` = off),
/// derived on the model itself as `sdkPathEnabled`/etc. (see
/// `KivySchoolData.swift`) rather than re-derived ad hoc in the view.
///
/// `global_tools` is a plain stored `Bool`, not a path, so it gets a
/// `ToggleField` rather than a gated one. It and `global_tools_path` sit
/// together inside a bordered box because the path only means anything while
/// the switch is on — grouped by a border rather than by indenting the path
/// under the switch.
@View
struct AndroidPathSettings {
    var section: KivySchoolData.AndroidData

    var body: some View {
        VStack(spacing: .sm) {
            Divider()

            GroupBox {
                VStack(spacing: .sm) {
                    ToggleField(
                        section: section,
                        isOnKeyPath: \.globalTools,
                        label: "Use global tools",
                        hint: "Off: use the project-local SDK/NDK in ./.kivyschool. On: use the shared ones in ~/.kivyschool (or Global tools path)."
                    )
                    ToggleGatedPathField(
                        section: section,
                        isOnKeyPath: \.globalToolsPathEnabled,
                        valueKeyPath: \.globalToolsPath,
                        label: "Global tools path",
                        placeholder: "~/.kivyschool"
                    )
                }
            }

            ToggleGatedPathField(
                section: section,
                isOnKeyPath: \.sdkPathEnabled,
                valueKeyPath: \.sdkPath,
                label: "Android sdk path",
                placeholder: "Enter your android sdk path here"
            )
            ToggleGatedPathField(
                section: section,
                isOnKeyPath: \.ndkPathEnabled,
                valueKeyPath: \.ndkPath,
                label: "Android ndk path",
                placeholder: "Enter your android ndk path here"
            )
            ToggleGatedPathField(
                section: section,
                isOnKeyPath: \.javaPathEnabled,
                valueKeyPath: \.javaPath,
                label: "Java path",
                placeholder: "Enter your jdk path here"
            )
        }
    }
}

/// A `Toggle` whose explanation is the hover tooltip rather than text under
/// it. These settings need a sentence to explain, and a sentence per toggle
/// is more than this narrow column can carry statically — it turns a list of
/// switches into a wall of prose. `title` puts it one hover away instead,
/// same as the platform rail's icons.
@View
struct ToggleField {
    var section: KivySchoolData.AndroidData
    var isOnKeyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, Bool>
    var label: String
    var hint: String = ""

    var body: some View {
        Toggle(isOn: boolBinding(isOnKeyPath, on: section)) { span(.class("text-sm text-gray-700 dark:text-gray-300")) { label } }
            .attributes(.custom(name: "title", value: hint))
    }
}

/// Extracted wrapper for a `Toggle` + conditionally-shown path `input`, used
/// by all four path fields above.
@View
struct ToggleGatedPathField {
    var section: KivySchoolData.AndroidData
    var isOnKeyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, Bool>
    var valueKeyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, String?>
    var label: String
    var placeholder: String

    var body: some View {
        VStack(spacing: .sm) {
            Toggle(isOn: boolBinding(isOnKeyPath, on: section)) { span(.class("text-sm text-gray-700 dark:text-gray-300")) { label } }
            if section[keyPath: isOnKeyPath] {
                input(.type(.text), .class(pathInputClass), .placeholder(placeholder))
                    .bindValue(optionalStringBinding(valueKeyPath, on: section))
            }
        }
    }
}

func boolBinding(
    _ keyPath: ReferenceWritableKeyPath<KivySchoolData.AndroidData, Bool>,
    on section: KivySchoolData.AndroidData
) -> Binding<Bool> {
    Binding(
        get: { section[keyPath: keyPath] },
        set: { section[keyPath: keyPath] = $0 }
    )
}

@View
struct ArchCheckboxRow {
    var section: KivySchoolData.AndroidData
    var arch: KivySchoolData.AndroidData.Arch
    var label: String

    var body: some View {
        HStack(alignment: .center, spacing: .sm) {
            input(.type(.checkbox), .class("h-4 w-4 text-indigo-600 rounded"))
                .bindChecked(Binding(
                    get: { section.archs.contains(arch) },
                    set: { isOn in
                        if isOn {
                            if !section.archs.contains(arch) { section.archs.append(arch) }
                        } else {
                            section.archs.removeAll { $0 == arch }
                        }
                    }
                ))
            span(.class("text-sm text-gray-700 dark:text-gray-300")) { label }
        }
        .attributes(.class("py-1"))
    }
}
