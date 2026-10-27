extension RuleCatalog {
    private static let adoptingLiquidGlass = "https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass"
    private static let softDeprecated = "Marked deprecated for a future release in the iOS 27 SDK (deprecated: 100000.0), so the compiler does not warn yet."

    static let liquidGlassRules: [Rule] = [
        Rule(
            id: "design-compatibility-mode",
            title: "UIDesignRequiresCompatibility is set",
            severity: .warning,
            category: .liquidGlass,
            message: "The app opts out of the Liquid Glass design with UIDesignRequiresCompatibility. The key was a temporary measure: the system ignores it when the app is built for iOS 27 or later.",
            replacement: "Remove the key (or INFOPLIST_KEY_UIDesignRequiresCompatibility) and fix the screens that look wrong with the current design.",
            evidence: "UIDesignRequiresCompatibility: \"The system ignores this key when you build for iOS 27 or later\"",
            documentation: "https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility",
            matcher: .project(.designCompatibilityMode)
        ),
        Rule(
            id: "custom-bar-background",
            title: "Custom bar background",
            severity: .info,
            category: .liquidGlass,
            message: "Custom backgrounds on navigation bars, toolbars and tab bars can cover Liquid Glass and the scroll edge effect.",
            replacement: "Remove the custom background and let the system choose it; keep it only where the design needs it and check the result on iOS 26.",
            evidence: "Adopting Liquid Glass: \"Reduce your use of custom backgrounds in controls and navigation elements.\"",
            documentation: adoptingLiquidGlass,
            matcher: .any([
                .call("configureWithOpaqueBackground", member: true, labels: .exactly([])),
                .member("barTintColor", excludedBases: []),
                .call("toolbarBackground", member: true, labels: .any)
            ])
        )
    ]

    static let swiftUIRules: [Rule] = [
        Rule(
            id: "text-concatenation",
            title: "Text + Text",
            severity: .warning,
            category: .swiftUI,
            message: "Concatenating Text values with + is deprecated in iOS 26.0.",
            replacement: "Interpolate instead: Text(\"\\(Text(\"Total\").bold()) \\(amount)\").",
            evidence: "SwiftUICore: static func + (Text, Text) — deprecated: 26.0, \"Use string interpolation on `Text` instead\"",
            documentation: "https://developer.apple.com/documentation/swiftui/text",
            matcher: .sequences([Pattern([.punctuation("+"), .identifier("Text"), .punctuation("(")])])
        ),
        Rule(
            id: "on-change-single-parameter",
            title: "onChange(of:perform:)",
            severity: .warning,
            category: .swiftUI,
            message: "onChange with a one-parameter action closure is deprecated in iOS 17.0.",
            replacement: "Use onChange(of:initial:_:) with a closure that takes no parameters or two (oldValue, newValue).",
            evidence: "SwiftUI: onChange(of:perform:) — deprecated: 17.0",
            documentation: "https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)-4psgg",
            matcher: .onChangeWithOneParameter
        ),
        Rule(
            id: "navigation-link-is-active",
            title: "NavigationLink(isActive:) and NavigationLink(tag:selection:)",
            severity: .warning,
            category: .swiftUI,
            message: "Programmatic navigation through a link's isActive or selection binding is deprecated in iOS 16.0.",
            replacement: "Use NavigationLink(value:label:) with navigationDestination(for:destination:), or navigationDestination(isPresented:destination:), inside a NavigationStack.",
            evidence: "SwiftUI: NavigationLink.init(destination:isActive:label:) — deprecated: 16.0",
            documentation: "https://developer.apple.com/documentation/swiftui/view/navigationdestination(ispresented:destination:)",
            matcher: .any([
                .call("NavigationLink", member: false, labels: .containing("isActive")),
                .call("NavigationLink", member: false, labels: .containing("selection"))
            ])
        ),
        softRule("navigation-view", "NavigationView", "NavigationView", replacement: "Use NavigationStack, or NavigationSplitView for multiple columns.",
                 documentation: "https://developer.apple.com/documentation/swiftui/navigationstack",
                 matcher: .sequences([Pattern([.identifier("NavigationView")])])),
        softRule("navigation-bar-title", ".navigationBarTitle", "navigationBarTitle(_:)", replacement: "Use .navigationTitle(_:), with .navigationBarTitleDisplayMode(_:) for the display mode.",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/navigationbartitledisplaymode(_:)",
                 matcher: .call("navigationBarTitle", member: true, labels: .any)),
        softRule("foreground-color", ".foregroundColor", "foregroundColor(_:)", replacement: "Use .foregroundStyle(_:).",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:)",
                 matcher: .call("foregroundColor", member: true, labels: .any)),
        softRule("corner-radius-modifier", ".cornerRadius", "cornerRadius(_:antialiased:)", replacement: "Use .clipShape(.rect(cornerRadius:)), or fill a RoundedRectangle.",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:)",
                 matcher: .call("cornerRadius", member: true, labels: .any)),
        softRule("navigation-bar-items", ".navigationBarItems", "navigationBarItems(leading:trailing:)", replacement: "Use .toolbar with ToolbarItem(placement: .topBarLeading) and .topBarTrailing.",
                 documentation: "https://developer.apple.com/documentation/swiftui/toolbaritem",
                 matcher: .call("navigationBarItems", member: true, labels: .any)),
        softRule("edges-ignoring-safe-area", ".edgesIgnoringSafeArea", "edgesIgnoringSafeArea(_:)", replacement: "Use .ignoresSafeArea(_:edges:).",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:)",
                 matcher: .call("edgesIgnoringSafeArea", member: true, labels: .any)),
        softRule("action-sheet", ".actionSheet", "actionSheet(isPresented:content:)", replacement: "Use .confirmationDialog(_:isPresented:titleVisibility:actions:).",
                 documentation: "https://developer.apple.com/documentation/swiftui/modal-presentations",
                 matcher: .call("actionSheet", member: true, labels: .any)),
        softRule("alert-content-closure", ".alert(isPresented:content:)", "alert(isPresented:content:)", replacement: "Use .alert(_:isPresented:actions:message:) with Button actions.",
                 documentation: "https://developer.apple.com/documentation/swiftui/modal-presentations",
                 matcher: .any([
                     .call("alert", member: true, labels: .exactly(["isPresented"])),
                     .call("alert", member: true, labels: .exactly(["isPresented", "content"])),
                     .call("alert", member: true, labels: .exactly(["item"])),
                     .call("alert", member: true, labels: .exactly(["item", "content"]))
                 ])),
        softRule("accent-color-modifier", ".accentColor", "accentColor(_:)", replacement: "Use .tint(_:), or the asset catalog's accent color.",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/tint(_:)-93mfq",
                 matcher: .call("accentColor", member: true, labels: .any)),
        softRule("autocapitalization-modifier", ".autocapitalization", "autocapitalization(_:)", replacement: "Use .textInputAutocapitalization(_:).",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/textinputautocapitalization(_:)",
                 matcher: .call("autocapitalization", member: true, labels: .any)),
        softRule("disable-autocorrection", ".disableAutocorrection", "disableAutocorrection(_:)", replacement: "Use .autocorrectionDisabled(_:).",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/autocorrectiondisabled(_:)",
                 matcher: .call("disableAutocorrection", member: true, labels: .any)),
        softRule("navigation-bar-hidden", ".navigationBarHidden", "navigationBarHidden(_:)", replacement: "Use .toolbar(.hidden, for: .navigationBar).",
                 documentation: "https://developer.apple.com/documentation/swiftui/view/toolbar(_:for:)",
                 matcher: .call("navigationBarHidden", member: true, labels: .any))
    ]

    /// A SwiftUI API marked deprecated for a future release (`deprecated: 100000.0`).
    private static func softRule(
        _ id: String,
        _ title: String,
        _ declaration: String,
        replacement: String,
        documentation: String,
        matcher: Matcher
    ) -> Rule {
        Rule(
            id: id,
            title: title,
            severity: .info,
            category: .swiftUI,
            message: "\(declaration) is soft-deprecated. " + softDeprecated,
            replacement: replacement,
            evidence: "SwiftUI.swiftinterface (iOS 27.1 SDK): \(declaration) — deprecated: 100000.0",
            documentation: documentation,
            matcher: matcher
        )
    }
}
