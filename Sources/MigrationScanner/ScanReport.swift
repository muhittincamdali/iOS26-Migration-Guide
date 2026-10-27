/// One place where a rule applies.
///
/// A finding carries the rule, the file and the position, never text copied from the file: a
/// report can be posted to a pull request or uploaded as an artifact without leaking source code
/// or the secrets that may be in it.
public struct Finding: Sendable, Hashable, Codable, Comparable {
    public let ruleID: String
    public let severity: Severity
    /// The path as the scan was given it, followed by the path inside a scanned directory.
    public let file: String
    /// `nil` when the finding is about a whole file, such as a binary property list.
    public let location: SourceLocation?

    public init(ruleID: String, severity: Severity, file: String, location: SourceLocation?) {
        self.ruleID = ruleID
        self.severity = severity
        self.file = file
        self.location = location
    }

    /// The rule that produced the finding.
    public var rule: Rule? { RuleCatalog.rule(id: ruleID) }

    public static func < (lhs: Finding, rhs: Finding) -> Bool {
        let left = (lhs.file, lhs.location?.line ?? 0, lhs.location?.column ?? 0, lhs.ruleID)
        let right = (rhs.file, rhs.location?.line ?? 0, rhs.location?.column ?? 0, rhs.ruleID)
        return left < right
    }
}

/// Something the scanner could not do, or a suppression comment it could not use.
public struct Notice: Sendable, Hashable, Codable, Comparable {
    public enum Kind: String, Sendable, Codable {
        /// The file is larger than ``ScanConfiguration/maximumFileSize`` and was skipped.
        case fileTooLarge = "file-too-large"
        /// The path does not exist or cannot be read.
        case unreadable
        /// ``ScanConfiguration/maximumFileCount`` files were scanned; the rest were not.
        case fileLimitReached = "file-limit-reached"
        /// A file named like an Info.plist is not a property list, or is one that the property list
        /// guard refuses to parse: nested too deep, or using XML markup or an encoding that the
        /// guard could read differently from the system parser.
        case invalidPropertyList = "invalid-property-list"
        /// A `migration-scan:` comment has an unknown command, no rule, or a rule that does not exist.
        case invalidDirective = "invalid-directive"
    }

    public let kind: Kind
    public let file: String?
    public let line: Int?

    public init(kind: Kind, file: String?, line: Int? = nil) {
        self.kind = kind
        self.file = file
        self.line = line
    }

    /// A fixed explanation for the kind; it never contains text from the scanned files.
    public var message: String {
        switch kind {
        case .fileTooLarge: "Skipped: the file is larger than the maximum file size."
        case .unreadable: "Skipped: the path does not exist or cannot be read."
        case .fileLimitReached: "Stopped: the maximum number of files was reached; later files were not scanned."
        case .invalidPropertyList: "Skipped: the file is not a valid property list, or it uses nesting, XML markup or an encoding that the scanner refuses to parse."
        case .invalidDirective: "Ignored: the migration-scan comment has an unknown command, names no rule, or names a rule that does not exist."
        }
    }

    public static func < (lhs: Notice, rhs: Notice) -> Bool {
        (lhs.file ?? "", lhs.line ?? 0, lhs.kind.rawValue) < (rhs.file ?? "", rhs.line ?? 0, rhs.kind.rawValue)
    }
}

/// The result of a scan.
public struct ScanReport: Sendable, Codable, Equatable {
    /// Sorted by file, line, column and rule.
    public let findings: [Finding]
    public let notices: [Notice]
    /// Files that were read and checked (Swift sources, property lists and build settings).
    public let filesScanned: Int

    public init(findings: [Finding], notices: [Notice], filesScanned: Int) {
        self.findings = findings.sorted()
        self.notices = notices.sorted()
        self.filesScanned = filesScanned
    }

    /// The number of findings with exactly this severity.
    public func count(of severity: Severity) -> Int {
        findings.reduce(0) { $0 + ($1.severity == severity ? 1 : 0) }
    }

    /// Whether any finding is at least as severe as `severity`.
    public func hasFindings(atLeast severity: Severity) -> Bool {
        findings.contains { $0.severity >= severity }
    }
}
