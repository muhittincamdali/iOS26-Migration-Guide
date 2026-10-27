import Foundation

/// The `--format json` document. Keys are sorted, so the same scan gives the same bytes.
struct JSONReport: Encodable {
    struct Summary: Encodable {
        let errors: Int
        let warnings: Int
        let info: Int
        let filesScanned: Int
    }

    struct Item: Encodable {
        let rule: String
        let severity: Severity
        let category: RuleCategory
        let title: String
        let message: String
        let replacement: String
        let documentation: URL
        let file: String
        let line: Int?
        let column: Int?
    }

    struct NoticeItem: Encodable {
        let kind: Notice.Kind
        let message: String
        let file: String?
        let line: Int?
    }

    let tool: String
    let version: String
    let summary: Summary
    let findings: [Item]
    let notices: [NoticeItem]

    init(_ report: ScanReport) {
        tool = "migration-scan"
        version = ReportFormatter.toolVersion
        summary = Summary(
            errors: report.count(of: .error),
            warnings: report.count(of: .warning),
            info: report.count(of: .info),
            filesScanned: report.filesScanned
        )
        findings = report.findings.compactMap { finding in
            guard let rule = finding.rule else { return nil }
            return Item(
                rule: rule.id,
                severity: finding.severity,
                category: rule.category,
                title: rule.title,
                message: rule.message,
                replacement: rule.replacement,
                documentation: rule.documentation,
                file: finding.file,
                line: finding.location?.line,
                column: finding.location?.column
            )
        }
        notices = report.notices.map { NoticeItem(kind: $0.kind, message: $0.message, file: $0.file, line: $0.line) }
    }

    static func render(_ report: ScanReport) -> String {
        encode(JSONReport(report))
    }

    static func encode(_ value: some Encodable) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        // Encoding these value types cannot fail: no floating-point values, no custom encoders.
        let data = (try? encoder.encode(value)) ?? Data("{}".utf8)
        return String(decoding: data, as: UTF8.self) + "\n"
    }
}
