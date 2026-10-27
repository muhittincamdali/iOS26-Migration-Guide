import Foundation

/// The output formats of a ``ScanReport``.
public enum ReportFormat: String, Sendable, CaseIterable {
    /// For people: each finding with its explanation and fix, then a summary.
    case text
    /// One `file:line:column: warning: …` line per finding, which Xcode shows in the issue
    /// navigator when the scanner runs in a Run Script build phase.
    case xcode
    /// GitHub Actions workflow commands, shown as annotations on the pull request.
    case github
    /// A stable JSON document for scripts.
    case json
    /// SARIF 2.1.0, for GitHub code scanning and other static analysis viewers.
    case sarif
}

/// Turns a ``ScanReport`` into text. Every path goes through ``OutputSanitizer``; all other text
/// comes from the rule catalog.
public enum ReportFormatter {
    /// The version written into JSON and SARIF reports.
    public static let toolVersion = "2.0.0"

    public static func format(_ report: ScanReport, as format: ReportFormat) -> String {
        switch format {
        case .text: text(report)
        case .xcode: xcode(report)
        case .github: github(report)
        case .json: JSONReport.render(report)
        case .sarif: SARIFReport.render(report)
        }
    }

    // MARK: - Text and Xcode

    static func position(_ file: String, _ location: SourceLocation?) -> String {
        let path = OutputSanitizer.sanitize(file)
        guard let location else { return path }
        return "\(path):\(location.line):\(location.column)"
    }

    private static func text(_ report: ScanReport) -> String {
        var lines: [String] = []
        for finding in report.findings {
            guard let rule = finding.rule else { continue }
            lines.append("\(position(finding.file, finding.location)): \(finding.severity.rawValue): \(rule.title) [\(rule.id)]")
            lines.append("    \(rule.message)")
            lines.append("    Fix: \(rule.replacement)")
            lines.append("    See: \(rule.documentation.absoluteString)")
        }
        for notice in report.notices {
            let place = notice.file.map { position($0, notice.line.map { SourceLocation(line: $0, column: 1) }) } ?? "migration-scan"
            lines.append("\(place): notice: \(notice.message)")
        }
        lines.append(summary(report))
        return lines.joined(separator: "\n") + "\n"
    }

    static func summary(_ report: ScanReport) -> String {
        func plural(_ count: Int, _ word: String) -> String { "\(count) \(word)\(count == 1 ? "" : "s")" }
        let counts = [
            plural(report.count(of: .error), "error"),
            plural(report.count(of: .warning), "warning"),
            "\(report.count(of: .info)) info"
        ]
        return counts.joined(separator: ", ") + " in " + plural(report.filesScanned, "file") + "."
    }

    private static func xcode(_ report: ScanReport) -> String {
        var lines = report.findings.compactMap { finding -> String? in
            guard let rule = finding.rule else { return nil }
            let kind = finding.severity == .info ? "note" : finding.severity.rawValue
            return "\(position(finding.file, finding.location)): \(kind): \(rule.title): \(rule.replacement) [\(rule.id)]"
        }
        lines += report.notices.map { notice in
            let place = notice.file.map { position($0, notice.line.map { SourceLocation(line: $0, column: 1) }) } ?? "migration-scan"
            return "\(place): note: \(notice.message)"
        }
        return lines.isEmpty ? "" : lines.joined(separator: "\n") + "\n"
    }

    // MARK: - GitHub

    private static func github(_ report: ScanReport) -> String {
        var lines: [String] = []
        for finding in report.findings {
            guard let rule = finding.rule else { continue }
            let command = switch finding.severity {
            case .error: "error"
            case .warning: "warning"
            case .info: "notice"
            }
            var properties = ["file=\(escapeProperty(OutputSanitizer.sanitize(finding.file)))"]
            if let location = finding.location {
                properties.append("line=\(location.line)")
                properties.append("col=\(location.column)")
            }
            properties.append("title=\(escapeProperty("\(rule.title) [\(rule.id)]"))")
            lines.append("::\(command) \(properties.joined(separator: ","))::\(escapeData("\(rule.message) Fix: \(rule.replacement)"))")
        }
        lines.append(escapeData(summary(report)))
        return lines.joined(separator: "\n") + "\n"
    }

    /// The escaping of `@actions/core` for a command's message.
    static func escapeData(_ text: String) -> String {
        text.replacingOccurrences(of: "%", with: "%25")
            .replacingOccurrences(of: "\r", with: "%0D")
            .replacingOccurrences(of: "\n", with: "%0A")
    }

    /// The escaping of `@actions/core` for a command's properties.
    static func escapeProperty(_ text: String) -> String {
        escapeData(text)
            .replacingOccurrences(of: ":", with: "%3A")
            .replacingOccurrences(of: ",", with: "%2C")
    }
}
