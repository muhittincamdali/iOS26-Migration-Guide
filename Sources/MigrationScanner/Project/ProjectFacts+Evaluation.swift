import Foundation

extension ProjectFacts {
    private static let generationSetting = "INFOPLIST_KEY_UIApplicationSceneManifest_Generation"
    private static let compatibilitySetting = "INFOPLIST_KEY_UIDesignRequiresCompatibility"

    /// Whether the file can hold Xcode build settings: a project file, an xcconfig, or an
    /// XcodeGen spec.
    static func isBuildSettingsFile(_ name: String) -> Bool {
        name == "project.pbxproj" || name.hasSuffix(".xcconfig") || name == "project.yml" || name == "project.yaml"
    }

    /// Records `KEY = YES;` (project files, xcconfig) and `KEY: YES` (XcodeGen) lines.
    mutating func recordBuildSettings(_ text: String, file: String) {
        for (offset, rawLine) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("//") || line.hasPrefix("#") { continue }
            for (setting, isGeneration) in [(Self.generationSetting, true), (Self.compatibilitySetting, false)] {
                guard Self.enables(setting, line) else { continue }
                let hit = BuildSetting(file: file, line: offset + 1)
                if isGeneration { sceneManifestGenerationSettings.append(hit) } else { designCompatibilitySettings.append(hit) }
            }
        }
    }

    /// `KEY = YES`, `KEY: YES`, `"KEY": "YES"` and `KEY[sdk=iphoneos*] = YES`, with an optional
    /// trailing `;`. The value must be YES or true: NO and $(inherited) do not count.
    private static func enables(_ setting: String, _ line: String) -> Bool {
        var rest = Substring(line)
        if rest.first == "\"" { rest = rest.dropFirst() }
        guard rest.hasPrefix(setting) else { return false }
        rest = rest.dropFirst(setting.count)
        if rest.first == "\"" { rest = rest.dropFirst() }
        if rest.first == "[", let close = rest.firstIndex(of: "]") { rest = rest[rest.index(after: close)...] }
        rest = rest.drop { $0 == " " || $0 == "\t" }
        guard let separator = rest.first, separator == "=" || separator == ":" else { return false }
        let value = rest.dropFirst()
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: ";\"'"))
            .uppercased()
        return value == "YES" || value == "TRUE"
    }

    // MARK: - Rules

    /// The findings of the project rules that are enabled.
    func findings(enabled: (ProjectCheck) -> Rule?) -> [Finding] {
        var findings: [Finding] = []
        let uiKitEntries = entryPoints.filter { $0.kind == .uiKitAppDelegate }
        let usesSwiftUILifeCycle = entryPoints.contains { $0.kind == .swiftUIApp }
        if !uiKitEntries.isEmpty, !usesSwiftUILifeCycle {
            let hasManifest = propertyLists.contains(where: \.hasSceneManifest) || !sceneManifestGenerationSettings.isEmpty
            let hasConfiguration = propertyLists.contains(where: \.hasSceneConfiguration) || implementsSceneConfigurationMethod
            let check: ProjectCheck? = !hasManifest ? .sceneManifestMissing : (!hasConfiguration ? .sceneConfigurationMissing : nil)
            if let check, let rule = enabled(check) {
                for entry in uiKitEntries where !entry.suppressions.suppresses(rule.id, line: entry.location.line) {
                    findings.append(Finding(ruleID: rule.id, severity: rule.severity, file: entry.file, location: entry.location))
                }
            }
        }
        if let rule = enabled(.designCompatibilityMode) {
            for list in propertyLists where list.requiresDesignCompatibility {
                let location = list.compatibilityKeyLine.map { SourceLocation(line: $0, column: 1) }
                findings.append(Finding(ruleID: rule.id, severity: rule.severity, file: list.file, location: location))
            }
            for setting in designCompatibilitySettings {
                let location = SourceLocation(line: setting.line, column: 1)
                findings.append(Finding(ruleID: rule.id, severity: rule.severity, file: setting.file, location: location))
            }
        }
        return findings
    }
}
