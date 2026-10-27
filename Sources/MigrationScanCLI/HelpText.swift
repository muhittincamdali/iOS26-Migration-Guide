import MigrationScanner

enum HelpText {
    static let usage = """
    USAGE: migration-scan [options] [path ...]

    Scans Swift sources, Info.plist files and Xcode build settings for what the iOS 26 and
    iOS 27 SDKs deprecate, ignore or refuse. Paths default to the current directory. Files are
    read, never changed.

    OPTIONS:
      --format <format>       text (default), xcode, github, json or sarif
      --fail-on <severity>    Exit with 1 when a finding is at least this severe:
                              error (default), warning, info or never
      --min-severity <level>  Leave out findings below info (default), warning or error
      --disable <ids>         Comma-separated rules to skip
      --only <ids>            Comma-separated rules to run, and no others
      --exclude <name>        Do not enter directories with this name (repeatable)
      --max-file-size <bytes> Skip larger files (default \(ScanConfiguration.defaultMaximumFileSize))
      --max-files <count>     Stop after this many files (default \(ScanConfiguration.defaultMaximumFileCount))
      --list-rules            List the rules (add --format json for JSON)
      --explain <id>          Explain one rule
      --version               Print the version
      -h, --help              Show this help

    SUPPRESSING A FINDING:
      let scale = UIScreen.main.scale // migration-scan:ignore uiscreen-main -- reason
      // migration-scan:ignore-file all

    EXIT STATUS:
      0  no finding at or above --fail-on
      1  at least one finding at or above --fail-on
      2  invalid command line, or a path that does not exist

    """
}

enum RuleListing {
    static func text() -> String {
        var lines: [String] = []
        let width = RuleCatalog.all.map(\.id.count).max() ?? 0
        for category in RuleCategory.allCases {
            let rules = RuleCatalog.rules(in: category)
            guard !rules.isEmpty else { continue }
            lines.append(category.title)
            for rule in rules {
                let id = rule.id.padding(toLength: width, withPad: " ", startingAt: 0)
                let severity = rule.severity.rawValue.padding(toLength: 7, withPad: " ", startingAt: 0)
                lines.append("  \(id)  \(severity)  \(rule.title)")
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    static func explanation(of rule: Rule) -> String {
        """
        \(rule.id) (\(rule.severity.rawValue), \(rule.category.title))
        \(rule.title)

        \(rule.message)

        Fix: \(rule.replacement)
        Based on: \(rule.evidence)
        See: \(rule.documentation.absoluteString)

        """
    }

    private struct Entry: Encodable {
        let id: String
        let title: String
        let severity: Severity
        let category: RuleCategory
        let message: String
        let replacement: String
        let evidence: String
        let documentation: String
    }

    static func json() -> String {
        let entries = RuleCatalog.all.map {
            Entry(
                id: $0.id, title: $0.title, severity: $0.severity, category: $0.category, message: $0.message,
                replacement: $0.replacement, evidence: $0.evidence, documentation: $0.documentation.absoluteString
            )
        }
        return JSONText.encode(entries)
    }
}
