import Foundation
import MigrationScanner
import Testing

/// The library code shown in GettingStarted.md and MigrationScanner.md, compiled here against the
/// public API only (no `@testable`). `RepositoryTests` checks that the articles still contain
/// these bodies line for line, so an article cannot drift from code that builds.
@Suite("Documentation snippets")
struct DocumentationSnippetTests {
    @Test("Getting started: scan with a minimum severity and print Xcode issues")
    func gettingStarted() {
        let scanner = ProjectScanner(configuration: ScanConfiguration(minimumSeverity: .warning))
        let report = scanner.scan(paths: [URL(filePath: "MyApp")])
        if report.hasFindings(atLeast: .error) {
            print(ReportFormatter.format(report, as: .xcode))
        }
        #expect(report.findings.isEmpty)
    }

    @Test("Overview: scan a folder and print a text report")
    func overview() {
        let report = ProjectScanner().scan(paths: [URL(filePath: "MyApp")])
        print(ReportFormatter.format(report, as: .text))
        #expect(report.findings.isEmpty)
    }
}
