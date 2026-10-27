import Foundation

/// How urgently a finding needs attention.
///
/// The order is `info < warning < error`, so `severity >= .warning` selects warnings and errors.
public enum Severity: String, Codable, Sendable, CaseIterable, Comparable {
    /// Soft-deprecated API or a design review point: nothing breaks yet.
    case info
    /// Deprecated API that still works, or a setting the latest SDK ignores.
    case warning
    /// Code or configuration that fails to compile or to launch with the current toolchain or SDK.
    case error

    private var rank: Int {
        switch self {
        case .info: 0
        case .warning: 1
        case .error: 2
        }
    }

    public static func < (lhs: Severity, rhs: Severity) -> Bool {
        lhs.rank < rhs.rank
    }
}

/// The migration topic a rule belongs to.
public enum RuleCategory: String, Codable, Sendable, CaseIterable {
    case sceneLifeCycle = "scene-life-cycle"
    case liquidGlass = "liquid-glass"
    case uiKit = "uikit"
    case swiftUI = "swiftui"
    case swiftLanguage = "swift-language"

    /// A short human-readable name.
    public var title: String {
        switch self {
        case .sceneLifeCycle: "Scene life cycle"
        case .liquidGlass: "Liquid Glass"
        case .uiKit: "UIKit"
        case .swiftUI: "SwiftUI"
        case .swiftLanguage: "Swift language"
        }
    }
}

/// One check the scanner runs, with the explanation it attaches to each finding.
///
/// Every source rule names the SDK declaration it was checked against in ``evidence``: the
/// deprecation message and version come from the iOS SDK headers and Swift interfaces, not from
/// memory. Browse all rules with ``RuleCatalog/all``.
public struct Rule: Sendable, Hashable, Identifiable {
    /// A stable, kebab-case identifier such as `uiscreen-main`, used in suppression comments and
    /// on the command line.
    public let id: String
    /// A one-line summary.
    public let title: String
    public let severity: Severity
    public let category: RuleCategory
    /// What is wrong and why it matters, written for someone who has not followed the release notes.
    public let message: String
    /// What to write instead.
    public let replacement: String
    /// The SDK declaration and version the rule is based on, e.g. `UIScreen.main, deprecated in iOS 26.0`.
    public let evidence: String
    /// Apple documentation for the replacement or the requirement.
    public let documentation: URL
    let matcher: Matcher

    init(
        id: String,
        title: String,
        severity: Severity,
        category: RuleCategory,
        message: String,
        replacement: String,
        evidence: String,
        documentation: String,
        matcher: Matcher
    ) {
        self.id = id
        self.title = title
        self.severity = severity
        self.category = category
        self.message = message
        self.replacement = replacement
        self.evidence = evidence
        // The catalog is static; a malformed URL is a programming error caught by the tests.
        self.documentation = URL(string: documentation)!
        self.matcher = matcher
    }

    /// Whether the rule looks at Swift source (as opposed to Info.plist files and build settings).
    public var isSourceRule: Bool {
        if case .project = matcher { return false }
        return true
    }

    public static func == (lhs: Rule, rhs: Rule) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
