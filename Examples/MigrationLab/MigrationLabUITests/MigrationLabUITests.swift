import XCTest

/// Runs the example app the way a person does: through its scene, its tabs and a URL.
@MainActor
final class MigrationLabUITests: XCTestCase {
    private let timeout: TimeInterval = 10

    override func setUp() {
        continueAfterFailure = false
    }

    private func launch(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments + ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        return app
    }

    func testScannerReportsTheLegacySample() {
        let app = launch()
        // The sample holds one Swift 6 error, six deprecations and one soft deprecation.
        XCTAssertTrue(app.staticTexts["1 error · 6 warnings · 1 info"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["UIWindow created without a scene"].exists)
    }

    func testEditingTheSourceRescans() {
        let app = launch()
        let clear = app.navigationBars.buttons["Clear"]
        XCTAssertTrue(clear.waitForExistence(timeout: timeout))
        clear.tap()
        XCTAssertTrue(app.staticTexts["0 errors · 0 warnings · 0 info"].waitForExistence(timeout: timeout))
        let editor = app.textViews.firstMatch
        editor.tap()
        editor.typeText("let scale = UIScreen.main.scale")
        XCTAssertTrue(app.staticTexts["0 errors · 1 warning · 0 info"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Line 1:22 · uiscreen-main"].exists)
        app.navigationBars.buttons["Load sample"].tap()
        XCTAssertTrue(app.staticTexts["1 error · 6 warnings · 1 info"].waitForExistence(timeout: timeout))
    }

    func testURLOpensTheRuleThroughTheSceneDelegate() throws {
        let app = launch(["-screen", "scene"])
        XCTAssertTrue(app.tabBars.buttons["Scene"].waitForExistence(timeout: timeout))
        XCUIDevice.shared.system.open(try XCTUnwrap(URL(string: "migrationlab://rule/uiscreen-main")))
        // The system asks before it opens another app's URL scheme from outside the app.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let confirm = springboard.alerts.firstMatch
        if confirm.waitForExistence(timeout: 3) {
            confirm.buttons.element(boundBy: confirm.buttons.count - 1).tap()
        }
        XCTAssertTrue(app.navigationBars["UIScreen.main"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Identifier, uiscreen-main"].exists)
        XCTAssertTrue(app.tabBars.buttons["Rules"].isSelected)
    }

    func testUnknownRuleURLIsIgnored() throws {
        let app = launch(["-rule", "no-such-rule"])
        XCTAssertTrue(app.navigationBars["Scanner"].waitForExistence(timeout: timeout))
    }

    func testRulesCanBeSearched() {
        let app = launch(["-screen", "rules"])
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: timeout))
        search.tap()
        search.typeText("keyWindow")
        XCTAssertTrue(app.staticTexts["uiapplication-key-window"].waitForExistence(timeout: timeout))
        XCTAssertFalse(app.staticTexts["uiscreen-main"].exists)
    }
}
