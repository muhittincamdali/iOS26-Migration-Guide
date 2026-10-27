import Foundation
import Testing
@testable import MigrationScanner

@Suite("Project rules")
struct ProjectRuleTests {
    private func projectIDs(_ report: ScanReport) -> [String] {
        report.findings.filter { RuleCatalog.rule(id: $0.ruleID)?.isSourceRule == false }.map(\.ruleID)
    }

    @Test("A UIKit app delegate without a scene manifest cannot launch on the iOS 27 SDK")
    func manifestMissing() throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate)
        try project.write("App/Info.plist", infoPlist("<key>CFBundleName</key><string>App</string>"))
        let report = project.scan()
        let finding = try #require(report.findings.first { $0.ruleID == "scene-manifest-missing" })
        #expect(finding.location == SourceLocation(line: 3, column: 1))
        #expect(finding.file.hasSuffix("App/AppDelegate.swift"))
        #expect(finding.severity == .error)
    }

    @Test("A manifest with a window scene configuration adopts scenes")
    func manifestWithConfiguration() throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate)
        try project.write("App/Info.plist", infoPlist(sceneManifestWithConfiguration))
        #expect(projectIDs(project.scan()).isEmpty)
    }

    @Test("A generated manifest has no configurations: the delegate method must provide one")
    func generatedManifest() throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate)
        try project.write("App.xcodeproj/project.pbxproj", "\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;\n")
        #expect(projectIDs(project.scan()) == ["scene-configuration-missing"])

        try project.write("App/SceneConfiguration.swift", """
        extension AppDelegate {
            func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
                let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
                configuration.delegateClass = SceneDelegate.self
                return configuration
            }
        }
        """)
        #expect(projectIDs(project.scan()).isEmpty)
    }

    @Test("Generation set to NO or inherited does not count", arguments: [
        "INFOPLIST_KEY_UIApplicationSceneManifest_Generation = NO;",
        "INFOPLIST_KEY_UIApplicationSceneManifest_Generation = \"$(inherited)\";",
        "// INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES"
    ])
    func generationDisabled(line: String) throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate)
        try project.write("Config/App.xcconfig", line + "\n")
        #expect(projectIDs(project.scan()) == ["scene-manifest-missing"])
    }

    @Test("A SwiftUI App creates its scenes, even with an adapted app delegate")
    func swiftUIApp() throws {
        let project = try TemporaryDirectory()
        try project.write("App/App.swift", """
        import SwiftUI

        @main
        struct InboxApp: App {
            @UIApplicationDelegateAdaptor private var delegate: AppDelegate
            var body: some Scene { WindowGroup { Text("Inbox") } }
        }

        final class AppDelegate: NSObject, UIApplicationDelegate {}
        """)
        #expect(projectIDs(project.scan()).isEmpty)
    }

    @Test("UIApplicationMain called from main.swift is a UIKit entry point")
    func mainSwift() throws {
        let project = try TemporaryDirectory()
        try project.write("App/main.swift", "import UIKit\n\nUIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))\n")
        let report = project.scan()
        #expect(report.findings.first { $0.ruleID == "scene-manifest-missing" }?.location == SourceLocation(line: 3, column: 1))
    }

    @Test("The entry point can suppress the scene rule")
    func suppressedEntryPoint() throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate.replacingOccurrences(
            of: "@main", with: "// migration-scan:ignore scene-manifest-missing -- watchOS companion only\n@main"))
        #expect(projectIDs(project.scan()).isEmpty)
    }

    @Test("UIDesignRequiresCompatibility in Info.plist, project files and XcodeGen specs")
    func designCompatibility() throws {
        let project = try TemporaryDirectory()
        try project.write("App/Info.plist", infoPlist("<key>UIDesignRequiresCompatibility</key>\n<true/>"))
        try project.write("App.xcodeproj/project.pbxproj", "a\n\t\tINFOPLIST_KEY_UIDesignRequiresCompatibility = YES;\n")
        try project.write("project.yml", "settings:\n  INFOPLIST_KEY_UIDesignRequiresCompatibility: true\n")
        try project.write("Other/Info.plist", infoPlist("<key>UIDesignRequiresCompatibility</key>\n<false/>"))
        let found = project.scan().findings.filter { $0.ruleID == "design-compatibility-mode" }
        #expect(found.count == 3)
        #expect(found.first { $0.file.hasSuffix("App/Info.plist") }?.location?.line == 5)
        #expect(found.first { $0.file.hasSuffix("project.pbxproj") }?.location?.line == 2)
        #expect(found.first { $0.file.hasSuffix("project.yml") }?.location?.line == 2)
    }

    @Test("A binary Info.plist is read too, without a line")
    func binaryPropertyList() throws {
        let project = try TemporaryDirectory()
        let data = try PropertyListSerialization.data(
            fromPropertyList: ["UIDesignRequiresCompatibility": true], format: .binary, options: 0)
        try project.write("App/Info.plist", data)
        let found = project.scan().findings.filter { $0.ruleID == "design-compatibility-mode" }
        #expect(found.count == 1)
        #expect(found.first?.location == nil)
    }

    @Test("A file named Info.plist that is not a property list is reported, not parsed")
    func invalidPropertyList() throws {
        let project = try TemporaryDirectory()
        try project.write("App/Info.plist", "not a property list")
        let report = project.scan()
        #expect(report.notices.map(\.kind) == [.invalidPropertyList])
    }

    @Test("Disabled project rules do not run")
    func disabledProjectRule() throws {
        let project = try TemporaryDirectory()
        try project.write("App/AppDelegate.swift", uiKitAppDelegate)
        let rules = RuleCatalog.all.filter { $0.id != "scene-manifest-missing" }
        #expect(projectIDs(project.scan(ScanConfiguration(rules: rules))).isEmpty)
    }
}
