import Foundation

/// What the project-level rules need to know, collected while the files are scanned.
struct ProjectFacts {
    enum EntryPointKind: Equatable {
        /// `@main` on an app delegate, `@UIApplicationMain`, or a `UIApplicationMain(…)` call.
        case uiKitAppDelegate
        /// `@main` on a SwiftUI `App`: SwiftUI creates the scenes.
        case swiftUIApp
    }

    struct EntryPoint {
        let kind: EntryPointKind
        let file: String
        let location: SourceLocation
        let suppressions: Suppressions
    }

    struct PropertyListFacts {
        let file: String
        let hasSceneManifest: Bool
        let hasSceneConfiguration: Bool
        let requiresDesignCompatibility: Bool
        /// The line of `<key>UIDesignRequiresCompatibility</key>` in an XML property list.
        let compatibilityKeyLine: Int?
    }

    struct BuildSetting {
        let file: String
        let line: Int
    }

    var entryPoints: [EntryPoint] = []
    var implementsSceneConfigurationMethod = false
    var propertyLists: [PropertyListFacts] = []
    /// `INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES`
    var sceneManifestGenerationSettings: [BuildSetting] = []
    /// `INFOPLIST_KEY_UIDesignRequiresCompatibility = YES`
    var designCompatibilitySettings: [BuildSetting] = []

    // MARK: - Swift sources

    mutating func recordSwiftSource(_ index: TokenIndex, file: String, suppressions: Suppressions) {
        let configurationMethod = Matcher.declaration("application", labels: ["_", "configurationForConnecting", "options"])
        if !index.locations(of: configurationMethod).isEmpty {
            implementsSceneConfigurationMethod = true
        }
        for (kind, location) in Self.entryPoints(in: index) {
            entryPoints.append(EntryPoint(kind: kind, file: file, location: location, suppressions: suppressions))
        }
    }

    /// `@main` followed by a declaration whose inheritance clause names `UIApplicationDelegate`
    /// or `App`, `@UIApplicationMain`, and top-level `UIApplicationMain(…)` calls.
    private static func entryPoints(in index: TokenIndex) -> [(EntryPointKind, SourceLocation)] {
        var result: [(EntryPointKind, SourceLocation)] = []
        for position in index.positions(of: "main") where index.token(at: position - 1)?.isPunctuation("@") == true {
            guard let kind = entryPointKind(after: position, in: index), let at = index.token(at: position - 1) else { continue }
            result.append((kind, at.location))
        }
        for position in index.positions(of: "UIApplicationMain") {
            guard let previous = index.token(at: position - 1) else {
                result.append((.uiKitAppDelegate, index.tokens[position].location))
                continue
            }
            if previous.isPunctuation("@") {
                result.append((.uiKitAppDelegate, previous.location))
            } else if !previous.isPunctuation("."), !previous.isIdentifier("func"),
                      index.token(at: position + 1)?.isPunctuation("(") == true {
                result.append((.uiKitAppDelegate, index.tokens[position].location))
            }
        }
        return result
    }

    /// Reads the declaration header after `@main` up to its opening brace.
    private static func entryPointKind(after position: Int, in index: TokenIndex) -> EntryPointKind? {
        let limit = min(index.tokens.count, position + 64)
        var passedColon = false
        for offset in (position + 1)..<limit {
            let current = index.tokens[offset]
            if current.isPunctuation("{") { break }
            if current.isPunctuation(":") { passedColon = true }
            guard passedColon, current.kind == .identifier else { continue }
            if current.text == "UIApplicationDelegate" { return .uiKitAppDelegate }
            if current.text == "App" { return .swiftUIApp }
        }
        return nil
    }

    // MARK: - Property lists and build settings

    private static let manifestKey = "UIApplicationSceneManifest"
    private static let configurationsKey = "UISceneConfigurations"
    private static let compatibilityKey = "UIDesignRequiresCompatibility"

    /// Whether the file name is one that Xcode uses for a target's Info.plist.
    static func isInfoPropertyList(_ name: String) -> Bool {
        name == "Info.plist" || name.hasSuffix("-Info.plist")
    }

    /// Returns `false` when the data is not a dictionary property list.
    mutating func recordPropertyList(_ data: Data, file: String) -> Bool {
        guard PropertyListGuard.isSafeToParse(data),
              let root = try? PropertyListSerialization.propertyList(from: data, format: nil),
              let dictionary = root as? [String: Any] else { return false }
        let manifest = dictionary[Self.manifestKey] as? [String: Any]
        let configurations = manifest?[Self.configurationsKey] as? [String: Any] ?? [:]
        let hasConfiguration = configurations.values.contains { (($0 as? [Any])?.isEmpty == false) }
        let requiresCompatibility = Self.isTrue(dictionary[Self.compatibilityKey])
        propertyLists.append(PropertyListFacts(
            file: file,
            hasSceneManifest: manifest != nil,
            hasSceneConfiguration: hasConfiguration,
            requiresDesignCompatibility: requiresCompatibility,
            compatibilityKeyLine: requiresCompatibility ? Self.line(of: "<key>\(Self.compatibilityKey)</key>", in: data) : nil
        ))
        return true
    }

    private static func isTrue(_ value: Any?) -> Bool {
        if let flag = value as? Bool { return flag }
        if let text = value as? String { return ["YES", "TRUE", "1"].contains(text.uppercased()) }
        return false
    }

    private static func line(of needle: String, in data: Data) -> Int? {
        let text = String(decoding: data, as: UTF8.self)
        for (offset, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() where line.contains(needle) {
            return offset + 1
        }
        return nil
    }
}
