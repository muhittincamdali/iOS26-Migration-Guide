import Foundation
import MigrationScanner
import SwiftUI

// The Swift code shown in README.md, compiled with the example app. A test checks that every
// Swift block of the README appears in the example's sources.

func scanProject(at folder: URL) -> String {
    let report = ProjectScanner().scan(paths: [folder])
    return ReportFormatter.format(report, as: .text)
}

func blockingFindings(in folder: URL) -> [Finding] {
    var configuration = ScanConfiguration(minimumSeverity: .warning)
    configuration.excludedDirectoryNames.insert("Generated")
    let report = ProjectScanner(configuration: configuration).scan(paths: [folder])
    return report.findings.filter { $0.severity == .error }
}

func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}

struct CaptionView: View {
    let caption: String

    var body: some View {
        Text(caption)
            .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
    }
}
