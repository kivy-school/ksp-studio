# Platform Sidebar + Light/Dark Mode — Plan

Reference: `ksp-studio/research/studio-pics/*.png` (kivy-school `ksproject-studio`, refactor_6_6 branch)
and https://github.com/kivy-school/ksproject-studio/tree/refactor_6_6/src/ksproject_studio

## What the reference shows

- Far-left rail (~64px, always dark), one icon per platform, vertically stacked:
  Python/uv, Android, Apple (iOS). Active one gets a left accent bar.
- Top bar: app name, right side has search / bell / apps-grid / **light-dark toggle**.
- Below top bar: big page title ("Android — HH:MM:SS"), then a horizontal
  sub-tab bar for that platform's sections (Android: Home, Permissions, Services,
  Miscellaneous — iOS: Home, Permissions, Miscellaneous).
- Kivy's rail is a platform switch, not a push/detail stack — selecting an icon
  just swaps which section's content is shown, nothing is "popped".

## Decision: tab-style state, not NavigationStack

`ElementaryViews`' `NavigationStack` is path/detail-drill-down (push a value, get a
destination, pop it). That's the wrong shape for a persistent 3-way rail
selector. Going with a plain `@State activePlatform: Platform` switch, the same
pattern already used for `MainPageTabBar`/`activePage` in `ProjectConfigApp.swift`.
`ElementaryViews.TabView` was also considered — same tab-bar shape, but it wants
`[TabItem]` + one content builder rather than three custom icon views, so it fit
the horizontal sub-tab bars better than the icon rail. Not used for either yet.

## Scope for this pass (Phase 1 — sidebar shell + theming)

1. `Platform` enum: `.python`, `.android`, `.apple` — icon + display name.
   Originally emoji, now real PNGs (`public/icons/{python,android,apple}64.png`,
   copied from the ksproject-studio assets dropped in `Sources/WebApp/assets/`
   — that folder itself isn't wired to anything; SPM just warns about the
   unhandled files sitting in the target's source tree).
2. New `PlatformSidebar` view: fixed-width dark rail, one button per `Platform`,
   left accent bar on the active one. Lives in `ProjectConfigApp.swift` next to
   the other nav chrome (`NavBar`, `MainPageTabBar`).
3. Wire `@State activePlatform` into `ProjectConfigApp`. Restructure the top
   level layout to `NavBar` then `HStack(rail, content)` (currently everything
   is inside one `main`, no rail).
4. Remove the duplicate `SidebarView` (Tools: VSCode / Terminal / Sequencer) —
   it's currently rendered on **both** left and right of the content
   (`ProjectConfigApp.swift:102` and `:121`, same args, looks like a
   copy-paste/debug leftover). Keep one instance, right-docked, unrelated to
   the new platform rail.
5. Content routing behind the rail, kept intentionally simple since the data
   model isn't split by platform yet:
   - `.python` / `.apple` → today's `ConfigurationView` unchanged (all five
     existing tabs: Project, Dependencies, PSProject, UV, Build System). No
     regression risk, nothing about the working save/load flow changes.
   - `.android` → placeholder view mirroring the reference's sub-tab labels
     (Home, Permissions, Services, Miscellaneous) with a "not implemented yet"
     body. There is no Android section in `ProjectModel`/backend yet, so real
     fields (package name, min/max/target API, NDK version, SDK/NDK paths,
     arch checkboxes, permissions list, services list, icon/presplash upload)
     are follow-up work, not this pass.
6. Light/dark toggle:
   - `index.html`: add `tailwind.config = { darkMode: 'class' }` so the CDN
     build supports a manual class toggle instead of only `prefers-color-scheme`.
   - Sun/moon button in `NavBar`, toggling `document.documentElement`'s `dark`
     class via `JSObject` (same direct-JS-interop style as `APIClient.swift`),
     persisted to `localStorage`, initial value from stored pref falling back
     to `prefers-color-scheme`.
   - Done via two mechanisms, not just Tailwind: (1) `dark:` variants added
     across the app's plain-Tailwind chrome (nav bar, rail, page background,
     `Components.swift` form fields, `ConfigurationView.swift` tab bars,
     `SidebarView`/`ProjectHeader`), and (2) a real `EnvironmentValues`
     entry — `AppColorScheme.swift` defines `@Entry var colorScheme` using
     ElementaryUI's actual `@Entry`/`@Environment`/`.environment(#Key(\.x), _)`
     machinery (it exists; there's just no built-in color-scheme key, and
     `CSSColorKey`/`Color`'s `resolve(in environment:...)` presently ignore
     the environment they're handed). `ProjectConfigApp` owns the `@State`
     and injects it at the root; `NavBar` toggles it via `@Binding` instead of
     owning private state. This is what makes the `BorderedLabel`/`CSSColorKey`
     -based editors (`InfoPlistEditor`, `EntitlementsEditor`,
     `CustomKeyValueRow`, `KnownKeyValueRow`) go dark too — they read
     `@Environment(#Key(\.colorScheme))` and pick a different `CSSColorKey`
     directly in Swift, since those take a fixed color enum, not a Tailwind
     class string a `dark:` variant could attach to.
   - Remaining untouched: `ValueInputRow`'s `ArrayView`/`DictionaryView` add
     buttons and a few saturated-color badges — left as-is since saturated
     Tailwind colors (green-500 etc.) read fine on both light and dark canvases.

## Phase 2 — Apple "Miscellaneous" sub-tab + form field style

Built directly from the kivy source (not just the screenshot): `research/studio-pics/ksproject-studio-refactor_6_6 2/src/ksproject_studio/View/EntrypointScreen/components/IOS/components/IMiscellaneous/imiscellaneous.kv` + the shared `View/components/{FileUploader,ImagePreview,PreviewPane,RoundedBoxLayout}`.

1. **Form fields → VStack.** `FormField` (`Components.swift`) was label-left/
   input-right; kivy's `CTextInputLayout` (see `IHome/ihome.kv`) is label-on-top,
   input below, optional helper text under that. Rebuilt `FormField` to match
   (`fieldLabel`, `value`, optional `helperText`/`placeholder`, `max-w-md` so
   short fields don't stretch full-width). Added the "Bundle id" /
   "e.g. com.kivyschool.yourapp" example verbatim to `PSProjectTab`'s "App Name"
   field. `BoolField` (checkbox) left label-left — that's a normal checkbox
   layout, not what was flagged.
2. **New reusable primitives** (per instruction: build composable `@View`s,
   not one-off screens):
   - `Card` (`Components.swift`) — generic rounded panel, kivy's
     `RoundedBoxLayout` equivalent.
   - `FileUploadField` / `ImagePreviewBox`
     (`Views/Components/FileUploadField.swift`) — kivy's `FileUploader` /
     `ImagePreview`. The upload button is a `<label for=hiddenInputID>`
     (pure HTML, no JS needed to open the picker). Picking a file is read
     via `FileReader.readAsDataURL`, bridged into `async/await` with
     `JSPromise(resolver:)` (`readFileAsDataURL(_:)`).
     Gotcha: Elementary's `.onInput` hands back a typed `InputEvent` whose
     `rawEvent` is `internal`, not `public` — can't reach `target.files`
     through it. Worked around by wiring a native `addEventListener("change",
     ...)` directly via `document.getElementById` in a `.task`, bypassing
     Elementary's event wrapper for this one case.
   - `PhoneMockup` / `IOSHomeMockup` / `IOSPresplashMockup`
     (`Views/Components/DeviceMockup.swift`) — kivy's `PreviewPane` /
     `IOSPane` / `IPresplashPane`. Generic device frame (bezel, dynamic
     island, home indicator) + two content builders on top: a wallpaper +
     live clock + dock (kivy's `ioswall2.jpg`/`appbar.svg`/`icontacts.svg`/
     `imessages.svg`/`icamera.svg`/`iphotos.svg`, copied into
     `public/device/` the same way the sidebar icons went into
     `public/icons/`), and a solid-color presplash preview.
     Gotcha hit and fixed: the dock's total width (4×36px icons + gaps +
     padding) slightly exceeded the phone frame's inner width, so the last
     icon (`iphotos.svg`) was silently clipped by the frame's
     `overflow-hidden`. Fixed by shrinking icon size/gap/padding, not by
     widening the frame.
   - Clock has no Foundation `Date` (see `APIClient.swift`'s "no Foundation
     encode/decode" convention) — `currentTimeHHMM()` reads straight from JS
     `Date` instead.
3. **New model fields** on `PSProjectSection` (`ProjectData.swift`): `icon`,
   `presplash`, `presplashColor`. Field names mirror kivy's `data.icon` /
   `data.presplash` / `data.presplash_color` attributes directly, matching how
   every other field here already maps 1:1 to the kivy model
   (`appName`↔`app_name`, `pipInstallApp`↔`pip_install_app`, etc). **Not
   verified against the actual backend/TOML schema** — there's no live Vapor
   server in this environment to round-trip against, so if the real backend
   uses different key names this'll need adjusting.
4. New `PSProjectSubTab.miscellaneous` case, wired to `IOSMiscellaneousTab`
   (`Views/IOSMiscellaneousTab.swift`): left column of two `Card`s (icon
   upload + preview, presplash upload + color field + preview), right column
   with the two live device mockups — verified end-to-end with a real file
   upload in a headless browser (upload → data URL → preview thumbnail →
   mockup updates live).

## Phase 3 — Fix: Miscellaneous was in the wrong place

Phase 2 nested the new Miscellaneous tab as a 6th sub-tab under the
pre-existing "PSProject" tab (itself buried inside "Project Configuration").
Wrong — kivy's own `ios.kv` shows selecting the Apple platform goes straight
to top-level **Home / Permissions / Miscellaneous** tabs, no intermediate
wrapper. Corrected:

- `ConfigTab` (`Project`/`Dependencies`/`UV`/`Build System`) is now
  Python-platform-only — dropped its `.psproject` case. These are general
  pyproject.toml concerns, not Apple-specific.
- New `AppleTab` (`Home`/`Permissions`/`Miscellaneous`) is the Apple
  platform's own top-level tab bar — matches `ios.kv`'s `CTabHeaderItem`s
  1:1. `AppleConfigView`/`AppleTabBar` in `ConfigurationView.swift`.
- `PSProjectSubTab` renamed to `AppleHomeSubTab`, demoted to being Home's
  *inner* sub-tabs (`Info`/`Backends`/`Info.plist`/`Entitlements`/
  `Swift Packages`) — kivy's `IHome` is just a bundle-id field, but this
  app's `[tool.psproject]` model carries more than that, so those extra
  concerns live as sub-tabs of Home rather than as more top-level tabs kivy
  doesn't have.
- New `ApplePermissionsTab` — kivy's `IPermissions` fetches known permission
  names from an API for a picker (`IPermissionsModal`); no such API exists
  here, so this is a plain add/remove list (reusing `ListEditor`) backed by
  a new `PSProjectSection.iosPermissions: [String]` field (mirrors kivy's
  `datamodel.ios_permissions`).
- `IOSMiscellaneousTab` itself didn't change — just moved from being invoked
  inside the old `PSProjectTab` to being a sibling top-level `AppleTab` case.
- Save button/message extracted into a shared `SaveConfigurationBar` (was
  duplicated logic inside one `ConfigurationView`; now both
  `PythonConfigView` and `AppleConfigView` reuse it).
- Verified in-browser: Apple sidebar icon → Home/Permissions/Miscellaneous
  directly; Python sidebar icon → Project/Dependencies/UV/Build System, no
  PSProject tab mixed in.

## Phase 4 — Android tab (Home / Permissions / Services / Miscellaneous)

Built from the kivy source directly (`research/.../EntrypointScreen/components/Android/`).
Lives in `Views/Sections/Android/`, routed from `ProjectConfigApp` via a new
`AndroidTab` enum + `AndroidConfigView`, exactly mirroring the Apple tab's shape.

- **New data path, deliberately separate from `ProjectModel`.** Early in this
  pass `KivySchoolData.AndroidData` (see Phase "KivySchoolData model" below —
  the real `pyproject_toml.py`-shaped model) got wired directly into the
  legacy `ProjectModel`; told explicitly to stop doing that. `RootModel.swift`
  is the result: a small separate root (`path` + `PyProjectToml`) that
  eagerly ensures `tool.kivySchool.android` is non-nil so it can be passed
  down the view tree by plain reference — no `@Binding` plumbing, no
  optional-unwrapping at call sites, mutations just work because `AndroidData`
  is itself `@Reactive`. `ProjectConfigApp` holds `@State var rootModel`
  alongside (not instead of) the existing `@State var model`; Python/Apple
  still run on the old `model` untouched.
- **Home**: package name + api levels + sdk/ndk versions (left grid, reusing
  `CardTextField`), arch checkboxes (right column). Kivy's home screen also
  has a Global-Tools toggle + sdk/ndk/java path fields with a "toggle
  enables/disables the field" idiom — **left out**. Every version of that
  (custom toggle component, plain `FormField`s, more/less div nesting, wasm
  memory bumped to 512MB initial/1GB max, even a same-day `elementary-ui`
  0.4.1→0.7.0 + `elementary` 0.7.1→0.8.1 bump) reproducibly crashed the wasm
  runtime once this one tab's total view count grew past what it is now.
  Symptoms varied run to run — `Index out of range` in
  `ElementaryUI.ScratchStack`/`BasicContainers.RigidArray`, `posix_memalign`/
  `dlmalloc` allocator failures, `swift_getTypeByMangledName` returning a null
  function — but every stack trace bottomed out in `elementary-ui`'s own
  view-mounting internals (`_MountContext`, `MountContainer`), not this app's
  code. Reads as a real capacity bug in that package's wasm32 mounting path,
  not something fixable by rearranging this file. (The `elementary-ui`/
  `elementary` version bump was reverted — 0.7.0 breaks `ElementaryViews`
  build outright, `Text` no longer conforms to `HTML`/`View` the same way,
  dozens of errors — a separate, much bigger migration if ever revisited.)
- **Permissions**: same simplification as `ApplePermissionsTab` — kivy fetches
  known permission names from an API for a picker; no such API here, so
  plain add/remove `ListEditor` on `AndroidData.permissions`.
- **Services**: card grid (`AndroidServiceCard`) + a modal form
  (`AndroidServiceFormModal`) for add/edit, structurally like `TerminalModal`.
  `ServiceStartType` is a local-only enum purely to drive `SelectField` —
  `ServiceData.startType` itself stays a plain `String` matching the model.
- **Miscellaneous**: same shape as `IOSMiscellaneousTab` (icon/presplash
  upload + color + live device mockups), reusing `Card`/`FileUploadField`/
  `ImagePreviewBox`. `AndroidHomeMockup`/`AndroidPresplashMockup`
  (`AndroidDeviceMockup.swift`) reuse the generic `PhoneMockup` frame with
  Android's own wallpaper/dock assets (`androidwall2.jpg`, `contacts.svg`,
  `messages.svg`, `camera.svg`, `photos.svg` — copied into `public/device/`
  the same way the iOS ones were).
- **`TwoColumnLayout` component** (`Components/TwoColumnLayout.swift`):
  the `flex flex-col lg:flex-row` + `flex-1 min-w-0` shell was hand-copied
  identically across `IOSMiscellaneousTab`, `AndroidMiscellaneousTab`, and
  `AndroidHomeTab` — factored out on request. Used in the first two; **not**
  used in `AndroidHomeTab`, which already sits at the edge of the crash above
  — wrapping it in one more generic view type was, empirically, enough to tip
  it over. Noted inline in that file. `AndroidHomeTab` also had its
  flex-row/divider/aside shell flattened to a single stacked column for the
  same reason (fewer wrapper `div`s).
- **Found (probably) the actual root cause of the "locks up" reports**:
  reproduced by the user as "sit on a Miscellaneous tab, then switch
  platforms" — not a static complexity ceiling after all, but
  `IOSHomeMockup`/`AndroidHomeMockup`'s live clock, which was a `@State var
  time` ticked once a second via `.task { while !Task.isCancelled { ...;
  try? await Task.sleep(...) } }`. Switching platforms/tabs while that loop
  is mid-`sleep` tears down the mockup's view, but the loop wakes up ~1s
  later and mutates `time` on a view that's already gone — a genuine
  teardown/background-task race, not a capacity limit. Matches every crash
  signature seen throughout this phase (all bottom out in `elementary-ui`'s
  mount internals, because that's what runs on the *next* mount after the
  heap gets corrupted, not necessarily where the corruption happened).
  First fix dropped the recurring task entirely (static reading, no more
  live clock) — worked, but per feedback that's a step backwards for no good
  reason: a per-view task racing that view's own teardown is the real bug,
  not "a task exists at all". Replaced with `Views/Components/Clock.swift`:
  a single `@Reactive final class Clock { static let shared }` that starts
  its *one* ticking task once, in `init()`, mutating only its own `time`
  property forever — never torn down with any particular view, so there's
  nothing for a view's unmount to race. `IOSHomeMockup`/`AndroidHomeMockup`
  just read `Clock.shared.time` now; no per-view `@State`/`.task` at all.
  Live-tick confirmed working again (read the clock, waited over a minute,
  value changed).

  Turned out the clock was never the cause at all: with the clock fully
  static (no task anywhere) the user's exact sequence — Apple Miscellaneous
  → Android Miscellaneous → Apple again — still crashed **20/20** times
  locally once tested with the right reproduction steps. Bisected further
  (`bisect2.mjs`) and found the real trigger: remounting `Misc` *within* one
  platform (Home→Misc→Home→Misc, no platform switch) is safe every time
  (0/5); it only breaks when the outer `switch activePlatform` in
  `ProjectConfigApp` tears down one concrete view tree and rebuilds a
  different one, then comes back to the original — a reconciler bug in
  `elementary-ui` itself, not this app's view code, and not the clock.
  **Actual fix**: `ProjectConfigApp.selectPlatform(_:)` now resets every
  platform's active sub-tab to `.home`/`.project` on every platform switch,
  so returning to a platform never auto-remounts a Miscellaneous tab through
  that exact path (an explicit click still mounts it fine, from within one
  platform). Verified: 0/20 on the previously-100%-reproducible sequence.
  The shared `Clock` stays — it just wasn't the fix, and per feedback there
  was no reason to give up the live tick over a hypothesis that turned out
  wrong.
- **Tried, then reverted, using `ElementaryViews`' `.frame`/`.cornerRadius`/
  `.shadow`/`.padding` modifiers in `Card`/`PhoneMockup`/the two device
  mockups** instead of raw `.class(...)` strings. Two independent problems
  surfaced: (1) each chained modifier wraps the element in another
  `_AttributedElement<...>` generic layer, and that additional view-tree
  depth alone was enough to reintroduce the exact platform-switch crash
  above (confirmed 10/10 fail with the modifiers, 0/20 without) — in the
  Misc/mockup subtree specifically, given its established fragility, more
  chained modifiers is a real cost, not a stylistic wash; (2) `.frame`'s
  original signature took `width: String?`/`height: String?` (a raw
  Tailwind size token), which is exactly as stringly-typed as the `.class`
  call it replaced — no actual type-safety gain to justify the risk. Fixed
  the second problem for real rather than dropping it: `.frame` in
  `ElementaryViews/Modifier/ViewModifiers.swift` now takes `some
  BinaryFloatingPoint` / `some BinaryInteger` (pixels, mirroring SwiftUI's
  `.frame(width: CGFloat?, ...)`), with no string-typed overload left at
  all — verified both `.frame(width: 240)` and `.frame(width: 240.0)`
  resolve without ambiguity. Also fixed a real, independent bug hit along
  the way: `CSSPadding.css` interpolated its `Double` `py` directly, so any
  whole-number value produced an invalid class like `py-6.0` (silently
  dropped by Tailwind) — `CSSPadding.swift` now formats whole numbers
  without the trailing `.0`. Both `ElementaryViews` fixes are real,
  worth keeping, and safe on their own; it's specifically *chaining several
  of them onto the Misc/mockup view tree* that isn't, for now.
- **wasm memory bumped regardless** (`Package.swift` `linkerSettings`):
  `--initial-memory=512MiB`/`--max-memory=1GiB` vs. the previous ~37MiB
  default. Didn't fix the Android crash above, but is a real, harmless
  improvement (the default was tight enough to be a plausible future problem
  on its own) — kept.
- Session-only: no save/load endpoint for the Android section yet, unlike
  Python/Apple's `SaveConfigurationBar` (would need to agree a wire shape
  with a real backend first — flagged in the UI with a small note).

## Explicit follow-ups (not in this pass)

- Revisit the dropped Home fields (global tools, sdk/ndk/java paths) —
  either by pruning total Home-tab view complexity further first, or after
  the `elementary-ui` capacity bug is understood/fixed upstream.
- Wire Android's save/load once a backend endpoint exists for the new
  `RootModel`/`PyProjectToml` shape (or decide to migrate `ProjectModel`
  itself onto it — a bigger, separate decision).
- Same per-platform split for Python/uv vs Apple content (right now both point
  at the same unsplit `ConfigurationView`).
- Verify the `icon`/`presplash`/`presplashColor` field names against the real
  backend once a Vapor server is available to test against.
- Top-bar icons from the reference (search / bell / apps grid) — not
  requested yet, skipping unless asked.
- Those loose original-app assets in `Sources/WebApp/assets/` (svgs, wallpapers,
  the non-square android/apple banner variants) are unused beyond the three
  64px icons copied into `public/icons/`. SPM warns about them each build;
  worth deciding whether to move them out of the Swift target's source tree,
  declare them as `resources:` in `Package.swift`, or just leave the warning.
