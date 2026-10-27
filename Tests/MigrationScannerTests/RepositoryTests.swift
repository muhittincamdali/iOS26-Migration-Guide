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

    @Test("Code in the guides and the README is copied from the example app", arguments: [
        "Sources/MigrationScanner/MigrationScanner.docc/AdoptingTheSceneLifeCycle.md",
        "Sources/MigrationScanner/MigrationScanner.docc/AdoptingLiquidGlass.md",
        "README.md"
    ])
    func copiedSnippets(document: String) throws {
        let text = try read(document)
        let folder = Self.root.appendingPathComponent("Examples/MigrationLab/MigrationLab")
        let sources = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
            .map { Self.normalized(try String(contentsOf: $0, encoding: .utf8)) }
        let blocks = Self.swiftBlocks(in: text)
        #expect(!blocks.isEmpty)
        // Package manifest snippets are not app code.
        for block in blocks where !block.hasPrefix("dependencies:") {
            let snippet = Self.normalized(block)
            #expect(sources.contains { $0.contains(snippet) }, "Not in the example app:\n\(block)")
        }
    }

    @Test("Code in the API articles builds as a test or is a clean scan", arguments: [
        "Sources/MigrationScanner/MigrationScanner.docc/GettingStarted.md",
        "Sources/MigrationScanner/MigrationScanner.docc/MigrationScanner.md"
    ])
    func articleSnippets(document: String) throws {
        let blocks = Self.swiftBlocks(in: try read(document))
        #expect(!blocks.isEmpty)
        let compiled = Self.normalized(try read("Tests/MigrationScannerTests/DocumentationSnippetTests.swift"))
        let libraryImport = "import MigrationScanner\n"
        for block in blocks {
            guard block.hasPrefix(libraryImport) else {
                // App code that shows suppression comments: every finding in it must be suppressed.
                let report = ProjectScanner().scan(source: block)
                #expect(report.findings.isEmpty && report.notices.isEmpty, "\(report.findings) \(report.notices)\n\(block)")
                continue
            }
            let body = block.dropFirst(libraryImport.count).trimmingCharacters(in: .newlines)
            #expect(compiled.contains(Self.normalized(body)), "Not in DocumentationSnippetTests.swift:\n\(block)")
        }
    }

    /// The contents of the ```swift blocks in a Markdown document.
    private static func swiftBlocks(in text: String) -> [String] {
        text.components(separatedBy: "```swift\n").dropFirst().compactMap { $0.components(separatedBy: "\n```").first }
    }

    /// Lines without their indentation, so a snippet can be shown at a different depth.
    private static func normalized(_ text: String) -> String {
        text.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
    }
}
#endif
