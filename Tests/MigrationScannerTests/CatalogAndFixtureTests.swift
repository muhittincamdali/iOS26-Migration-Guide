import Foundation
import Testing
@testable import MigrationScanner

@Suite("Rule catalog")
struct CatalogTests {
    @Test("Identifiers are unique kebab-case words")
    func identifiers() {
        let ids = RuleCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
        for id in ids {
            #expect(id.allSatisfy { $0.isLowercase || $0.isNumber || $0 == "-" }, "\(id)")
            #expect(!id.hasPrefix("-") && !id.hasSuffix("-") && !id.contains("--"), "\(id)")
            #expect(id != "all", "'all' is reserved for suppression comments")
        }
    }

    @Test("Every rule explains itself and links to its source", arguments: RuleCatalog.all)
    func explanations(rule: Rule) {
        #expect(!rule.title.isEmpty)
        #expect(rule.message.hasSuffix("."))
        #expect(rule.replacement.hasSuffix("."))
        #expect(!rule.evidence.isEmpty)
        #expect(rule.documentation.scheme == "https")
        #expect(["developer.apple.com", "github.com"].contains(rule.documentation.host()))
        #expect(RuleCatalog.rule(id: rule.id) == rule)
    }

    @Test("Categories partition the catalog")
    func categories() {
        let total = RuleCategory.allCases.map { RuleCatalog.rules(in: $0).count }.reduce(0, +)
        #expect(total == RuleCatalog.all.count)
        #expect(RuleCategory.allCases.allSatisfy { !RuleCatalog.rules(in: $0).isEmpty })
    }

    @Test("Severity order")
    func severityOrder() {
        #expect(Severity.info < .warning && Severity.warning < .error)
        #expect(Severity.allCases.sorted() == [.info, .warning, .error])
    }
}

@Suite("Legacy app fixture")
struct LegacyFixtureTests {
    /// The fixture is a small UIKit app as it looked before iOS 26. The test pins every finding,
    /// so a change to any rule shows up here as a reviewable difference.
    @Test("Every finding in the legacy app, in order")
    func legacyApp() throws {
        let root = try #require(Bundle.module.url(forResource: "LegacyApp", withExtension: nil, subdirectory: "Fixtures"))
        let report = ProjectScanner().scan(paths: [root])
        let found = report.findings.map { finding in
            "\(URL(fileURLWithPath: finding.file).lastPathComponent):\(finding.location?.line ?? 0) \(finding.ruleID)"
        }
        #expect(found == [
            "AppDelegate.swift:3 scene-manifest-missing",
            "AppDelegate.swift:3 ui-application-main-attribute",
            "AppDelegate.swift:11 uiwindow-without-scene",
            "AppDelegate.swift:11 uiscreen-main",
            "AppDelegate.swift:14 launch-options-key",
            "AppDelegate.swift:20 app-delegate-life-cycle-method",
            "AppDelegate.swift:21 application-icon-badge-number",
            "AppDelegate.swift:24 app-delegate-open-url",
            "AppDelegate.swift:27 open-url-options-key",
            "InboxViewController.swift:8 bar-button-style-done",
            "InboxViewController.swift:10 search-bar-placement-inline",
            "InboxViewController.swift:13 custom-bar-background",
            "InboxViewController.swift:18 uiscreen-main",
            "InboxViewController.swift:21 can-open-url",
            "InboxViewController.swift:22 open-url-synchronous",
            "Info.plist:7 design-compatibility-mode",
            "SettingsView.swift:8 navigation-view",
            "SettingsView.swift:11 on-change-single-parameter",
            "SettingsView.swift:14 text-concatenation",
            "SettingsView.swift:16 navigation-bar-title",
            "SettingsView.swift:17 alert-content-closure"
        ])
        #expect(report.notices.isEmpty)
        #expect(report.filesScanned == 4)
    }
}
