import ElementaryUI

/// App-wide light/dark scheme, threaded through the view tree via `@Environment`
/// (ElementaryUI ships the generic `@Entry`/`@Environment` mechanism but no
/// pre-built color-scheme key, and `CSSColorKey`/`Color`'s `resolve(in
/// environment:...)` currently ignore the environment they're handed — so this
/// is our own key, read explicitly wherever a view needs to pick a different
/// `CSSColorKey` in dark mode instead of relying on a static Tailwind `dark:` class).
enum AppColorScheme: String, Sendable, Equatable {
    case light
    case dark
}

extension EnvironmentValues {
    @Entry var colorScheme: AppColorScheme = .light
}
