import Foundation
import MigrationScanner
import Testing

/// The library code shown in GettingStarted.md and MigrationScanner.md, compiled here against the
/// public API only (no `@testable`). `RepositoryTests` checks that the articles still contain
/// these bodies line for line, so an article cannot drift from code that builds.
///
/// Each test runs its snippet unchanged against a real folder called `MyApp`. Two local
/// functions make that possible: `URL(filePath:)` resolves the snippet's relative path inside a
/// temporary directory instead of the process's working directory, which other tests share, and
/// `print(_:)` captures what the snippet prints so the test can check it.
@Suite("Documentation snippets")
struct DocumentationSnippetTests {
    /// App code with one finding of each severity: an error, a warning and an info.
    private static let legacySource = """
        import SwiftUI
        import UIKit

        func openHelp(_ url: URL) {
            UIApplication.shared.openURL(url)
        }

        let scale = UIScreen.main.scale

        struct HelpView: View {
            var body: some View { Text("Help").foregroundColor(.blue) }
        }
        """

    private static func makeApp() throws -> TemporaryDirectory {
        let directory = try TemporaryDirectory()
        try directory.write("MyApp/HelpView.swift", legacySource)
        return directory
    }

    @Test("Getting started: scan with a minimum severity and print Xcode issues")
    func gettingStarted() throws {
        let app = try Self.makeApp()
        func URL(filePath path: String) -> Foundation.URL { app.url.appendingPathComponent(path) }
        var output = ""
        func print(_ text: String) { output += text }

        let scanner = ProjectScanner(configuration: ScanConfiguration(minimumSeverity: .warning))
        let report = scanner.scan(paths: [URL(filePath: "MyApp")])
        if report.hasFindings(atLeast: .error) {
            print(ReportFormatter.format(report, as: .xcode))
        }

        #expect(report.filesScanned == 1)
        #expect(report.findings.map(\.ruleID) == ["open-url-synchronous", "uiscreen-main"])
        let file = app.url.appendingPathComponent("MyApp/HelpView.swift").path
        let lines = output.split(separator: "\n")
        try #require(lines.count == 2, "\(output)")
        #expect(lines[0].hasPrefix("\(file):5:26: error: UIApplication.openURL(_:): "), "\(lines[0])")
        #expect(lines[0].hasSuffix("[open-url-synchronous]"))
        #expect(lines[1].hasPrefix("\(file):8:22: warning: UIScreen.main: "), "\(lines[1])")
        #expect(lines[1].hasSuffix("[uiscreen-main]"))
    }

    @Test("Overview: scan a folder and print a text report")
    func overview() throws {
        let app = try Self.makeApp()
        func URL(filePath path: String) -> Foundation.URL { app.url.appendingPathComponent(path) }
        var output = ""
        func print(_ text: String) { output += text }

        let report = ProjectScanner().scan(paths: [URL(filePath: "MyApp")])
        print(ReportFormatter.format(report, as: .text))

        #expect(report.findings.map(\.ruleID) == ["open-url-synchronous", "uiscreen-main", "foreground-color"])
        let file = app.url.appendingPathComponent("MyApp/HelpView.swift").path
        #expect(output.contains("\(file):5:26: error: UIApplication.openURL(_:) [open-url-synchronous]\n"), "\(output)")
        #expect(output.contains(": warning: UIScreen.main [uiscreen-main]\n"))
        #expect(output.contains(": info: .foregroundColor [foreground-color]\n"))
        #expect(output.contains("    Fix: Use .foregroundStyle(_:).\n"))
        #expect(output.hasSuffix("1 error, 1 warning, 1 info in 1 file.\n"))
    }
}
