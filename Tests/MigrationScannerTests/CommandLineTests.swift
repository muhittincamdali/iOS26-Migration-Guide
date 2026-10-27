import Foundation
import MigrationScanCLI
import Testing
@testable import MigrationScanner

@Suite("Command line")
struct CommandLineTests {
    private func options(_ arguments: [String]) throws -> ScanOptions {
        guard case .scan(let options) = try CommandLineParser.parse(arguments) else {
            Issue.record("Expected a scan for \(arguments)")
            return ScanOptions()
        }
        return options
    }

    private func run(_ arguments: [String]) -> (code: MigrationScanCommand.ExitCode, output: String, errors: String) {
        var output = ""
        var errors = ""
        let code = MigrationScanCommand.run(arguments, standardOutput: { output += $0 }, standardError: { errors += $0 })
        return (code, output, errors)
    }

    @Test("Defaults: the current directory, text, fail on errors")
    func defaults() throws {
        let parsed = try options([])
        #expect(parsed.paths == ["."])
        #expect(parsed.format == .text)
        #expect(parsed.failOn == .error)
        #expect(parsed.configuration.rules.count == RuleCatalog.all.count)
    }

    @Test("Options and paths in any order; -- ends the options")
    func parsing() throws {
        let parsed = try options([
            "App", "--format", "sarif", "--fail-on", "never", "--disable", "uiscreen-main, navigation-view",
            "--exclude", "Generated", "--max-file-size", "1024", "--max-files", "10", "--", "--weird-name"
        ])
        #expect(parsed.paths == ["App", "--weird-name"])
        #expect(parsed.format == .sarif)
        #expect(parsed.failOn == nil)
        #expect(parsed.disabledRules == ["uiscreen-main", "navigation-view"])
        #expect(parsed.configuration.excludedDirectoryNames.contains("Generated"))
        #expect(parsed.configuration.maximumFileSize == 1024)
        #expect(parsed.configuration.maximumFileCount == 10)
        #expect(!parsed.configuration.rules.contains { $0.id == "uiscreen-main" })
    }

    @Test("--only keeps just the named rules")
    func only() throws {
        let parsed = try options(["--only", "uiscreen-main", "--only", "can-open-url"])
        #expect(Set(parsed.configuration.rules.map(\.id)) == ["uiscreen-main", "can-open-url"])
    }

    @Test("Numbers must be whole, positive and within the limit", arguments: [
        "0", "-1", "1.5", "1e6", "", " 12", "0x10", "١٢", "99999999999999999999999999", "1073741825"
    ])
    func invalidNumbers(value: String) {
        #expect(throws: CommandLineError.self) { try CommandLineParser.parse(["--max-file-size", value]) }
    }

    @Test("Usage errors name the problem", arguments: [
        (["--format", "html"], "Invalid value 'html' for --format"),
        (["--fail-on", "fatal"], "Invalid value 'fatal' for --fail-on"),
        (["--disable", "no-such-rule"], "There is no rule 'no-such-rule'"),
        (["--disable", " , "], "Invalid value ' , ' for --disable"),
        (["--exclude", "a/b"], "Invalid value 'a/b' for --exclude"),
        (["--explain"], "The option --explain needs a value."),
        (["--colour"], "Unknown option '--colour'"),
        (["--format", "\u{1B}[2J"], "Invalid value '\\u{1B}[2J' for --format")
    ])
    func usageErrors(arguments: [String], message: String) {
        let result = run(arguments)
        #expect(result.code == .usage)
        #expect(result.errors.contains(message))
        #expect(result.output.isEmpty)
    }

    @Test("A path that does not exist is a usage error")
    func missingPath() {
        let result = run(["/no/such/folder/for/migration-scan"])
        #expect(result.code == .usage)
        #expect(result.errors.contains("no such file or directory"))
    }

    @Test("Exit codes follow --fail-on")
    func exitCodes() throws {
        let project = try TemporaryDirectory()
        try project.write("App.swift", "let s = UIScreen.main\nNavigationView {}")
        let path = project.url.path
        #expect(run([path]).code == .success)
        #expect(run([path, "--fail-on", "warning"]).code == .findings)
        #expect(run([path, "--fail-on", "info", "--min-severity", "warning"]).code == .findings)
        #expect(run([path, "--fail-on", "info", "--disable", "uiscreen-main,navigation-view"]).code == .success)
        try project.write("Main.swift", "UIApplication.shared.openURL(url)")
        #expect(run([path]).code == .findings)
        #expect(run([path, "--fail-on", "never"]).code == .success)
    }

    @Test("--list-rules, --explain, --version and --help")
    func informationCommands() throws {
        let listing = run(["--list-rules", "--format", "json"])
        let rules = try #require(try JSONSerialization.jsonObject(with: Data(listing.output.utf8)) as? [[String: String]])
        #expect(rules.map { $0["id"] } == RuleCatalog.all.map(\.id))
        #expect(run(["--list-rules"]).output.contains("uiscreen-main"))
        let explanation = run(["--explain", "scene-manifest-missing"]).output
        #expect(explanation.contains("Based on: TN3187"))
        #expect(run(["--version"]).output == "migration-scan \(ReportFormatter.toolVersion)\n")
        #expect(run(["--help"]).output.contains("USAGE: migration-scan"))
    }
}
