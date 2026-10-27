#if os(macOS)
import Foundation
import Testing
@testable import MigrationScanner

/// Checks that the documentation and the example app stay in step with the code. These tests
/// read the repository's own files, so they run on macOS only.
@Suite("Repository")
struct RepositoryTests {
    private static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

    private func read(_ path: String) throws -> String {
        try String(contentsOf: Self.root.appendingPathComponent(path), encoding: .utf8)
    }

    @Test("The example app passes its own scan")
    func exampleIsMigrated() {
        let report = ProjectScanner().scan(paths: [Self.root.appendingPathComponent("Examples/MigrationLab")])
        #expect(report.findings.isEmpty, "\(report.findings)")
        #expect(report.notices.isEmpty)
        #expect(report.filesScanned >= 10)
    }

    @Test("The rule catalog article lists every rule with its severity")
    func catalogArticle() throws {
        let article = try read("Sources/MigrationScanner/MigrationScanner.docc/RuleReference.md")
        #expect(article.contains("All \(RuleCatalog.all.count) rules"))
        for rule in RuleCatalog.all {
            #expect(article.contains("| `\(rule.id)`: "), "\(rule.id) is missing; run scripts/rule-catalog.mjs")
            #expect(article.contains("| \(rule.severity.rawValue) |"))
        }
        let listed = article.components(separatedBy: "\n").filter { $0.hasPrefix("| `") }
        #expect(listed.count == RuleCatalog.all.count)
    }

    @Test("Code in the guides is copied from the example app", arguments: [
        ("AdoptingTheSceneLifeCycle.md", "SceneDelegate.swift"),
        ("AdoptingLiquidGlass.md", "GlassScreen.swift")
    ])
    func guideSnippets(article: String, source: String) throws {
        let guide = try read("Sources/MigrationScanner/MigrationScanner.docc/\(article)")
        let code = try read("Examples/MigrationLab/MigrationLab/\(source)")
        let normalizedCode = Self.normalized(code)
        let blocks = guide.components(separatedBy: "```swift\n").dropFirst().compactMap { $0.components(separatedBy: "\n```").first }
        #expect(!blocks.isEmpty)
        for block in blocks {
            #expect(normalizedCode.contains(Self.normalized(block)), "Not in \(source):\n\(block)")
        }
    }

    /// Lines without their indentation, so a snippet can be shown at a different depth.
    private static func normalized(_ text: String) -> String {
        text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
    }
}
#endif
