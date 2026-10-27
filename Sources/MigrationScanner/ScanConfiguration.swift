/// What a scan checks and how much it is allowed to read.
public struct ScanConfiguration: Sendable, Equatable {
    /// 4 MiB: far above any hand-written Swift file, small enough that a stray video named
    /// `Info.plist` costs nothing.
    public static let defaultMaximumFileSize = 4 * 1_024 * 1_024
    public static let defaultMaximumFileCount = 100_000
    /// Folders that hold build output or third-party code.
    public static let defaultExcludedDirectoryNames: Set<String> = [
        ".build", ".git", ".swiftpm", "build", "DerivedData", "SourcePackages", "Pods", "Carthage", "node_modules"
    ]

    /// The rules to run. Defaults to ``RuleCatalog/all``.
    public var rules: [Rule]
    /// Findings below this severity are left out of the report.
    public var minimumSeverity: Severity
    /// Files larger than this many bytes are skipped with a ``Notice``. At least 1.
    public var maximumFileSize: Int {
        didSet { maximumFileSize = max(1, maximumFileSize) }
    }
    /// The scan stops after this many files with a ``Notice``. At least 1.
    public var maximumFileCount: Int {
        didSet { maximumFileCount = max(1, maximumFileCount) }
    }
    /// Directories with one of these names are not entered.
    public var excludedDirectoryNames: Set<String>

    public init(
        rules: [Rule] = RuleCatalog.all,
        minimumSeverity: Severity = .info,
        maximumFileSize: Int = ScanConfiguration.defaultMaximumFileSize,
        maximumFileCount: Int = ScanConfiguration.defaultMaximumFileCount,
        excludedDirectoryNames: Set<String> = ScanConfiguration.defaultExcludedDirectoryNames
    ) {
        self.rules = rules
        self.minimumSeverity = minimumSeverity
        self.maximumFileSize = max(1, maximumFileSize)
        self.maximumFileCount = max(1, maximumFileCount)
        self.excludedDirectoryNames = excludedDirectoryNames
    }

    func runs(_ rule: Rule) -> Bool {
        rule.severity >= minimumSeverity && rules.contains(rule)
    }
}
