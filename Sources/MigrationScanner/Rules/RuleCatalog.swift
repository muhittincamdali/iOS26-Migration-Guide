import Foundation

/// Every rule the scanner knows, grouped by ``RuleCategory``.
public enum RuleCatalog {
    /// All rules, in a stable order: by category, then as listed in each category.
    public static let all: [Rule] = sceneLifeCycleRules + uiKitRules + liquidGlassRules + swiftUIRules + swiftLanguageRules

    private static let byID: [String: Rule] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    /// The rule with the given identifier, or `nil`.
    public static func rule(id: String) -> Rule? {
        byID[id]
    }

    /// The rules of one category.
    public static func rules(in category: RuleCategory) -> [Rule] {
        all.filter { $0.category == category }
    }

    static let swiftLanguageRules: [Rule] = [
        Rule(
            id: "ui-application-main-attribute",
            title: "@UIApplicationMain and @NSApplicationMain are errors in Swift 6",
            severity: .error,
            category: .swiftLanguage,
            message: "SE-0383 deprecates these attributes; in the Swift 6 language mode the compiler rejects them.",
            replacement: "Write @main on the app delegate class instead.",
            evidence: "Swift 6.4: \"'UIApplicationMain' is deprecated\" is an error with -swift-version 6",
            documentation: "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0383-deprecate-uiapplicationmain-and-nsapplicationmain.md",
            matcher: .sequences([
                Pattern([.punctuation("@"), .identifier("UIApplicationMain")]),
                Pattern([.punctuation("@"), .identifier("NSApplicationMain")])
            ])
        )
    ]
}
