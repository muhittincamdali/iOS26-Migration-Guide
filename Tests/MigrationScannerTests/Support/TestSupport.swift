import Foundation
import Testing
@testable import MigrationScanner

extension Rule: CustomTestStringConvertible {
    public var testDescription: String { id }
}

/// The rule identifiers found in a Swift source, in report order.
func ruleIDs(in source: String, configuration: ScanConfiguration = ScanConfiguration()) -> [String] {
    ProjectScanner(configuration: configuration).scan(source: source).findings.map(\.ruleID)
}

/// The findings of one rule in a Swift source.
func findings(of ruleID: String, in source: String) -> [Finding] {
    ProjectScanner().scan(source: source).findings.filter { $0.ruleID == ruleID }
}

/// A directory under the system's temporary folder that is removed when the value is released.
final class TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("MigrationScannerTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    /// Writes `contents` to `path` (relative to the directory), creating folders as needed.
    @discardableResult
    func write(_ path: String, _ contents: String) throws -> URL {
        try write(path, Data(contents.utf8))
    }

    @discardableResult
    func write(_ path: String, _ data: Data) throws -> URL {
        let file = url.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: file)
        return file
    }

    func scan(_ configuration: ScanConfiguration = ScanConfiguration()) -> ScanReport {
        ProjectScanner(configuration: configuration).scan(paths: [url])
    }
}

/// An XML Info.plist with the given body inside the top-level dictionary.
func infoPlist(_ body: String) -> String {
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    \(body)
    </dict>
    </plist>
    """
}

let sceneManifestWithConfiguration = """
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    """

let uiKitAppDelegate = """
    import UIKit

    @main
    final class AppDelegate: UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            true
        }
    }
    """
