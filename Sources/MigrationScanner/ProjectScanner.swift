import Foundation

/// Scans Swift sources, Info.plist files and Xcode build settings for code and configuration
/// that the iOS 26 and iOS 27 SDKs deprecate, ignore or refuse.
///
/// ```swift
/// let report = ProjectScanner().scan(paths: [URL(filePath: "MyApp")])
/// for finding in report.findings {
///     print(finding.file, finding.location?.line ?? 0, finding.rule?.title ?? finding.ruleID)
/// }
/// ```
///
/// The scanner reads files and never changes them. It is synchronous; call it from a background
/// task for large projects.
public struct ProjectScanner: Sendable {
    public let configuration: ScanConfiguration
    private let sourceRules: [Rule]
    private let projectRules: [ProjectCheck: Rule]

    public init(configuration: ScanConfiguration = ScanConfiguration()) {
        self.configuration = configuration
        let enabled = Set(configuration.rules.map(\.id))
        let rules = RuleCatalog.all.filter { enabled.contains($0.id) && $0.severity >= configuration.minimumSeverity }
        sourceRules = rules.filter(\.isSourceRule)
        var projectRules: [ProjectCheck: Rule] = [:]
        for rule in rules {
            if case .project(let check) = rule.matcher { projectRules[check] = rule }
        }
        self.projectRules = projectRules
    }

    /// Checks one Swift source text with the source rules. The project rules need Info.plist
    /// files and build settings, so they only run in ``scan(paths:)``.
    public func scan(source: String, file: String = "Source.swift") -> ScanReport {
        guard source.utf8.count <= configuration.maximumFileSize else {
            return ScanReport(findings: [], notices: [Notice(kind: .fileTooLarge, file: file)], filesScanned: 0)
        }
        var facts = ProjectFacts()
        let result = scanSwift(source, file: file, facts: &facts)
        return ScanReport(findings: result.findings, notices: result.notices, filesScanned: 1)
    }

    /// Scans files and directories. Directories are searched for `.swift` files, `Info.plist`
    /// and `*-Info.plist` files, `project.pbxproj`, `.xcconfig` files and XcodeGen
    /// `project.yml` specs.
    public func scan(paths: [URL]) -> ScanReport {
        let (files, walkNotices) = FileWalker(configuration: configuration).collect(paths)
        var findings: [Finding] = []
        var notices = walkNotices
        var facts = ProjectFacts()
        var scanned = 0
        for file in files {
            guard let data = read(file.url) else {
                notices.append(Notice(kind: .unreadable, file: file.displayPath))
                continue
            }
            guard data.count <= configuration.maximumFileSize else {
                notices.append(Notice(kind: .fileTooLarge, file: file.displayPath))
                continue
            }
            scanned += 1
            switch file.kind {
            case .swiftSource:
                let result = scanSwift(String(decoding: data, as: UTF8.self), file: file.displayPath, facts: &facts)
                findings += result.findings
                notices += result.notices
            case .propertyList:
                if !facts.recordPropertyList(data, file: file.displayPath) {
                    notices.append(Notice(kind: .invalidPropertyList, file: file.displayPath))
                }
            case .buildSettings:
                facts.recordBuildSettings(String(decoding: data, as: UTF8.self), file: file.displayPath)
            }
        }
        findings += facts.findings { projectRules[$0] }
        return ScanReport(findings: findings, notices: notices, filesScanned: scanned)
    }

    private func scanSwift(_ source: String, file: String, facts: inout ProjectFacts) -> (findings: [Finding], notices: [Notice]) {
        let lexed = Lexer.lex(source)
        let index = TokenIndex(tokens: lexed.tokens)
        let suppressions = Suppressions(comments: lexed.comments)
        var findings = Set<Finding>()
        for rule in sourceRules {
            for location in index.locations(of: rule.matcher) where !suppressions.suppresses(rule.id, line: location.line) {
                findings.insert(Finding(ruleID: rule.id, severity: rule.severity, file: file, location: location))
            }
        }
        facts.recordSwiftSource(index, file: file, suppressions: suppressions)
        let notices = suppressions.invalidDirectiveLines.map { Notice(kind: .invalidDirective, file: file, line: $0) }
        return (Array(findings), notices)
    }

    /// Reads at most one byte more than the size limit, so a file that grows while it is read,
    /// or a device file that never ends, costs a bounded amount of memory.
    private func read(_ url: URL) -> Data? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        let (limit, overflow) = configuration.maximumFileSize.addingReportingOverflow(1)
        do {
            return try handle.read(upToCount: overflow ? Int.max : limit) ?? Data()
        } catch {
            return nil
        }
    }
}
