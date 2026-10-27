import Foundation

/// A SARIF 2.1.0 log with one run. Upload it with `github/codeql-action/upload-sarif` to see the
/// findings in GitHub code scanning.
struct SARIFReport: Encodable {
    struct Text: Encodable { let text: String }

    struct Configuration: Encodable { let level: String }

    struct ReportingDescriptor: Encodable {
        let id: String
        let name: String
        let shortDescription: Text
        let fullDescription: Text
        let help: Text
        let helpUri: URL
        let defaultConfiguration: Configuration
    }

    struct Driver: Encodable {
        let name: String
        let version: String
        let informationUri: URL
        let rules: [ReportingDescriptor]
    }

    struct Tool: Encodable { let driver: Driver }

    struct Region: Encodable {
        let startLine: Int
        let startColumn: Int
    }

    struct ArtifactLocation: Encodable { let uri: String }

    struct PhysicalLocation: Encodable {
        let artifactLocation: ArtifactLocation
        let region: Region?
    }

    struct Location: Encodable { let physicalLocation: PhysicalLocation }

    struct Result: Encodable {
        let ruleId: String
        let ruleIndex: Int
        let level: String
        let message: Text
        let locations: [Location]
    }

    struct Run: Encodable {
        let tool: Tool
        let columnKind: String
        let results: [Result]
    }

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case version
        case runs
    }

    let schema = "https://json.schemastore.org/sarif-2.1.0.json"
    let version = "2.1.0"
    let runs: [Run]

    static func level(_ severity: Severity) -> String {
        switch severity {
        case .error: "error"
        case .warning: "warning"
        case .info: "note"
        }
    }

    /// A relative path becomes a percent-encoded relative URI, an absolute one a `file://` URI.
    static func uri(for path: String) -> String {
        var trimmed = Substring(path)
        while trimmed.hasPrefix("./") { trimmed = trimmed.dropFirst(2) }
        let encoded = String(trimmed).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return trimmed.hasPrefix("/") ? "file://" + encoded : encoded
    }

    init(_ report: ScanReport) {
        let catalog = RuleCatalog.all
        let indexByID = Dictionary(uniqueKeysWithValues: catalog.enumerated().map { ($1.id, $0) })
        let descriptors = catalog.map { rule in
            ReportingDescriptor(
                id: rule.id,
                name: rule.title,
                shortDescription: Text(text: rule.title),
                fullDescription: Text(text: rule.message),
                help: Text(text: rule.replacement),
                helpUri: rule.documentation,
                defaultConfiguration: Configuration(level: Self.level(rule.severity))
            )
        }
        let results = report.findings.compactMap { finding -> Result? in
            guard let rule = finding.rule, let ruleIndex = indexByID[rule.id] else { return nil }
            let region = finding.location.map { Region(startLine: $0.line, startColumn: $0.column) }
            let location = PhysicalLocation(artifactLocation: ArtifactLocation(uri: Self.uri(for: finding.file)), region: region)
            return Result(
                ruleId: rule.id,
                ruleIndex: ruleIndex,
                level: Self.level(finding.severity),
                message: Text(text: "\(rule.message) \(rule.replacement)"),
                locations: [Location(physicalLocation: location)]
            )
        }
        let driver = Driver(
            name: "migration-scan",
            version: ReportFormatter.toolVersion,
            // A constant, checked by the tests.
            informationUri: URL(string: "https://github.com/muhittincamdali/iOS26-Migration-Guide")!,
            rules: descriptors
        )
        runs = [Run(tool: Tool(driver: driver), columnKind: "unicodeCodePoints", results: results)]
    }

    static func render(_ report: ScanReport) -> String {
        JSONReport.encode(SARIFReport(report))
    }
}
