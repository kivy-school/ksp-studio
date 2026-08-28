import ElementaryUI

/// Shared shell for the "form fields on the left, something else on the
/// right" layout used by `AndroidHomeTab`, `IOSMiscellaneousTab`, and
/// `AndroidMiscellaneousTab` — was hand-copied as raw `div(.class(...))`
/// pairs in each; factored out once it showed up a third time.
@View
struct TwoColumnLayout<Main: View, Trailing: View> {
    var main: Main
    var trailing: Trailing
    typealias Tag = HTMLTag.div

    init(@HTMLBuilder main: () -> Main, @HTMLBuilder trailing: () -> Trailing) {
        self.main = main()
        self.trailing = trailing()
    }

    var body: some View {
        div(.class("flex flex-col lg:flex-row gap-6 items-start")) {
            div(.class("flex-1 min-w-0")) {
                main
            }
            trailing
        }
    }
}
