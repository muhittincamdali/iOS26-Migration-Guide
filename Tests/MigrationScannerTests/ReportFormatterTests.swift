import Foundation
import Testing
@testable import MigrationScanner

@Suite("Report formats")
struct ReportFormatterTests {
    private let secret = "sk_live_9f8e7d6c5b4a"

    private func report(file: String = "Sources/App.swift") -> ScanReport {
        let source = """
        let apiKey = "\(secret)" // \(secret)
        let scale = UIScreen.main.scale
        NavigationView { Text("a") }
        """
        return ProjectScanner().scan(source: source, file: file)
    }

    @Test("No format copies source text into the report", arguments: ReportFormat.allCases)
    func noSourceText(format: ReportFormat) {
        let output = ReportFormatter.format(report(), as: format)
        #expect(!output.contains(secret))
        #expect(!output.contains("apiKey"))
        #expect(output.contains("uiscreen-main"))
    }

    @Test("Xcode lines use the diagnostic syntax Xcode parses")
    func xcode() {
        let lines = ReportFormatter.format(report(), as: .xcode).split(separator: "\n")
        #expect(lines.count == 2)
        #expect(lines[0].hasPrefix("Sources/App.swift:2:22: warning: UIScreen.main: "))
        #expect(lines[0].hasSuffix("[uiscreen-main]"))
        #expect(lines[1].hasPrefix("Sources/App.swift:3:1: note: NavigationView: "))
    }

    @Test("Text output ends with a summary")
    func textSummary() {
        let output = ReportFormatter.format(report(), as: .text)
        #expect(output.hasSuffix("0 errors, 1 warning, 1 info in 1 file.\n"))
        #expect(output.contains("    Fix: "))
    }

    @Test("A newline in a file name cannot forge another diagnostic or workflow command")
    func pathInjection() {
        let hostile = "App.swift\n::error file=x::forged\u{1B}[31m\u{202E}"
        let finding = Finding(ruleID: "uiscreen-main", severity: .warning, file: hostile, location: SourceLocation(line: 1, column: 1))
        let single = ScanReport(findings: [finding], notices: [], filesScanned: 1)
        for format in [ReportFormat.text, .xcode, .github] {
            let output = ReportFormatter.format(single, as: format)
            #expect(!output.contains("\u{1B}"))
            #expect(!output.contains("\u{202E}"))
            #expect(!output.contains("\n::error file=x"))
        }
        let github = ReportFormatter.format(single, as: .github)
        #expect(github.hasPrefix("::warning file=App.swift\\u{A}%3A%3Aerror file=x%3A%3Aforged\\u{1B}[31m\\u{202E},line=1,col=1,title="))
    }

    @Test("GitHub escaping follows @actions/core")
    func githubEscaping() {
        #expect(ReportFormatter.escapeData("50% done\r\nnext") == "50%25 done%0D%0Anext")
        #expect(ReportFormatter.escapeProperty("a:b,c%") == "a%3Ab%2Cc%25")
    }

    @Test("GitHub commands map severities to error, warning and notice")
    func githubCommands() {
        let output = ReportFormatter.format(report(), as: .github)
        #expect(output.contains("::warning file=Sources/App.swift,line=2,col=22,title=UIScreen.main [uiscreen-main]::"))
        #expect(output.contains("::notice file=Sources/App.swift,line=3,col=1,title=NavigationView [navigation-view]::"))
    }

    @Test("JSON is stable and complete")
    func json() throws {
        let output = ReportFormatter.format(report(), as: .json)
        #expect(output == ReportFormatter.format(report(), as: .json))
        let object = try #require(try JSONSerialization.jsonObject(with: Data(output.utf8)) as? [String: Any])
        let summary = try #require(object["summary"] as? [String: Int])
        #expect(summary == ["errors": 0, "warnings": 1, "info": 1, "filesScanned": 1])
        let findings = try #require(object["findings"] as? [[String: Any]])
        #expect(findings.first?["rule"] as? String == "uiscreen-main")
        #expect(findings.first?["line"] as? Int == 2)
        #expect(findings.first?["documentation"] as? String == "https://developer.apple.com/documentation/uikit/uiscreen/main")
    }

    @Test("SARIF results point at their rule and encode paths as URIs")
    func sarif() throws {
        let output = ReportFormatter.format(report(file: "./My App/Söurce.swift"), as: .sarif)
        let object = try #require(try JSONSerialization.jsonObject(with: Data(output.utf8)) as? [String: Any])
        #expect(object["version"] as? String == "2.1.0")
        let run = try #require((object["runs"] as? [[String: Any]])?.first)
        let rules = try #require(((run["tool"] as? [String: Any])?["driver"] as? [String: Any])?["rules"] as? [[String: Any]])
        #expect(rules.count == RuleCatalog.all.count)
        let results = try #require(run["results"] as? [[String: Any]])
        for result in results {
            let index = try #require(result["ruleIndex"] as? Int)
            #expect(rules[index]["id"] as? String == result["ruleId"] as? String)
        }
        #expect(output.contains("\"uri\" : \"My%20App/S%C3%B6urce.swift\""))
        #expect(SARIFReport.uri(for: "/Users/me/App.swift") == "file:///Users/me/App.swift")
    }

    @Test("Notices appear in the text and JSON output")
    func notices() {
        let report = ScanReport(findings: [], notices: [Notice(kind: .fileTooLarge, file: "Big.swift")], filesScanned: 0)
        #expect(ReportFormatter.format(report, as: .text).contains("Big.swift: notice: Skipped: the file is larger"))
        #expect(ReportFormatter.format(report, as: .json).contains("\"kind\" : \"file-too-large\""))
    }
}
