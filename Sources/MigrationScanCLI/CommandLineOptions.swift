import MigrationScanner

/// What the command line asks for.
public enum Invocation: Equatable, Sendable {
    case scan(ScanOptions)
    case listRules(ReportFormat)
    case explain(String)
    case help
    case version
}

/// The options of a scan.
public struct ScanOptions: Equatable, Sendable {
    public var paths: [String] = ["."]
    public var format: ReportFormat = .text
    /// `nil` never fails.
    public var failOn: Severity? = .error
    public var minimumSeverity: Severity = .info
    public var disabledRules: Set<String> = []
    public var onlyRules: Set<String>?
    public var excludedDirectoryNames: Set<String> = []
    public var maximumFileSize = ScanConfiguration.defaultMaximumFileSize
    public var maximumFileCount = ScanConfiguration.defaultMaximumFileCount

    public init() {}

    /// The scanner configuration these options describe.
    public var configuration: ScanConfiguration {
        let rules = RuleCatalog.all.filter { rule in
            !disabledRules.contains(rule.id) && (onlyRules?.contains(rule.id) ?? true)
        }
        return ScanConfiguration(
            rules: rules,
            minimumSeverity: minimumSeverity,
            maximumFileSize: maximumFileSize,
            maximumFileCount: maximumFileCount,
            excludedDirectoryNames: ScanConfiguration.defaultExcludedDirectoryNames.union(excludedDirectoryNames)
        )
    }
}

/// A command line that cannot be run. The message names the option and the accepted values;
/// it repeats a rejected value only after ``OutputSanitizer`` has made it printable.
public enum CommandLineError: Error, Equatable, CustomStringConvertible {
    case unknownOption(String)
    case missingValue(String)
    case invalidValue(option: String, value: String, expected: String)
    case unknownRule(String)

    public var description: String {
        switch self {
        case .unknownOption(let option):
            "Unknown option '\(OutputSanitizer.sanitize(option))'. Run migration-scan --help for the options."
        case .missingValue(let option):
            "The option \(option) needs a value."
        case .invalidValue(let option, let value, let expected):
            "Invalid value '\(OutputSanitizer.sanitize(value))' for \(option): expected \(expected)."
        case .unknownRule(let id):
            "There is no rule '\(OutputSanitizer.sanitize(id))'. Run migration-scan --list-rules for the rule identifiers."
        }
    }
}

/// Parses `migration-scan` arguments (without the program name).
public enum CommandLineParser {
    /// The largest accepted `--max-file-size`: 1 GiB.
    public static let maximumFileSizeLimit = 1 << 30
    /// The largest accepted `--max-files`.
    public static let maximumFileCountLimit = 10_000_000

    public static func parse(_ arguments: [String]) throws(CommandLineError) -> Invocation {
        var options = ScanOptions()
        var paths: [String] = []
        var listRules = false
        var remaining = arguments[...]
        while let argument = remaining.popFirst() {
            if argument == "--" {
                paths += remaining
                break
            }
            guard argument.hasPrefix("-"), argument != "-" else {
                paths.append(argument)
                continue
            }
            switch argument {
            case "-h", "--help": return .help
            case "--version": return .version
            case "--list-rules": listRules = true
            case "--explain":
                let id = try value(for: argument, from: &remaining)
                guard RuleCatalog.rule(id: id) != nil else { throw .unknownRule(id) }
                return .explain(id)
            case "--format":
                options.format = try choice(for: argument, from: &remaining, ReportFormat.init(rawValue:), expected: "text, xcode, github, json or sarif")
            case "--fail-on":
                let raw = try value(for: argument, from: &remaining)
                if raw == "never" {
                    options.failOn = nil
                } else {
                    guard let severity = Severity(rawValue: raw) else {
                        throw .invalidValue(option: argument, value: raw, expected: "error, warning, info or never")
                    }
                    options.failOn = severity
                }
            case "--min-severity":
                options.minimumSeverity = try choice(for: argument, from: &remaining, Severity.init(rawValue:), expected: "info, warning or error")
            case "--disable":
                options.disabledRules.formUnion(try ruleList(for: argument, from: &remaining))
            case "--only":
                options.onlyRules = (options.onlyRules ?? []).union(try ruleList(for: argument, from: &remaining))
            case "--exclude":
                let name = try value(for: argument, from: &remaining)
                guard !name.isEmpty, !name.contains("/") else {
                    throw .invalidValue(option: argument, value: name, expected: "a directory name without '/'")
                }
                options.excludedDirectoryNames.insert(name)
            case "--max-file-size":
                options.maximumFileSize = try integer(for: argument, from: &remaining, upTo: maximumFileSizeLimit)
            case "--max-files":
                options.maximumFileCount = try integer(for: argument, from: &remaining, upTo: maximumFileCountLimit)
            default:
                throw .unknownOption(argument)
            }
        }
        if listRules { return .listRules(options.format) }
        if !paths.isEmpty { options.paths = paths }
        return .scan(options)
    }

    private static func value(for option: String, from remaining: inout ArraySlice<String>) throws(CommandLineError) -> String {
        guard let value = remaining.popFirst() else { throw .missingValue(option) }
        return value
    }

    private static func choice<Value>(
        for option: String,
        from remaining: inout ArraySlice<String>,
        _ make: (String) -> Value?,
        expected: String
    ) throws(CommandLineError) -> Value {
        let raw = try value(for: option, from: &remaining)
        guard let parsed = make(raw) else { throw .invalidValue(option: option, value: raw, expected: expected) }
        return parsed
    }

    /// Comma-separated rule identifiers, each of which must exist.
    private static func ruleList(for option: String, from remaining: inout ArraySlice<String>) throws(CommandLineError) -> Set<String> {
        let raw = try value(for: option, from: &remaining)
        let ids = raw.split(separator: ",").map { String($0).trimmingSpaces() }.filter { !$0.isEmpty }
        guard !ids.isEmpty else { throw .invalidValue(option: option, value: raw, expected: "one or more rule identifiers") }
        for id in ids where RuleCatalog.rule(id: id) == nil {
            throw .unknownRule(id)
        }
        return Set(ids)
    }

    /// A decimal integer from 1 to `limit`. `Int(_:)` returns `nil` for anything that does not fit
    /// in an `Int`, so very long numbers are rejected instead of wrapping or trapping.
    private static func integer(for option: String, from remaining: inout ArraySlice<String>, upTo limit: Int) throws(CommandLineError) -> Int {
        let raw = try value(for: option, from: &remaining)
        guard raw.allSatisfy(\.isASCII), let number = Int(raw), (1...limit).contains(number) else {
            throw .invalidValue(option: option, value: raw, expected: "a whole number from 1 to \(limit)")
        }
        return number
    }
}

private extension String {
    func trimmingSpaces() -> String {
        String(drop { $0 == " " }.reversed().drop { $0 == " " }.reversed())
    }
}
