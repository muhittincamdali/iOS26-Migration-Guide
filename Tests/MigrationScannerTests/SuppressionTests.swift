import Testing
@testable import MigrationScanner

@Suite("Suppression comments")
struct SuppressionTests {
    @Test("ignore after code applies to its own line only")
    func sameLine() {
        let source = """
        let a = UIScreen.main // migration-scan:ignore uiscreen-main -- widget extension
        let b = UIScreen.main
        """
        #expect(findings(of: "uiscreen-main", in: source).map(\.location?.line) == [2])
    }

    @Test("ignore on a line of its own applies to the next line")
    func nextLine() {
        let source = """
        // migration-scan:ignore uiscreen-main
        let a = UIScreen.main
        let b = UIScreen.main
        """
        #expect(findings(of: "uiscreen-main", in: source).map(\.location?.line) == [3])
    }

    @Test("Several rules, separated by commas or spaces, and all")
    func ruleLists() {
        let source = """
        let w = UIWindow(frame: UIScreen.main.bounds) // migration-scan:ignore uiwindow-without-scene,uiscreen-main
        let x = UIWindow(frame: UIScreen.main.bounds) // migration-scan:ignore uiwindow-without-scene uiscreen-main
        let y = UIWindow(frame: UIScreen.main.bounds) /* migration-scan:ignore all */
        let z = UIWindow(frame: UIScreen.main.bounds) // migration-scan:ignore uiscreen-main
        """
        #expect(ruleIDs(in: source) == ["uiwindow-without-scene"])
    }

    @Test("ignore-file applies everywhere in the file, from any line")
    func fileWide() {
        let source = """
        let a = UIScreen.main
        let b = UIApplication.shared.keyWindow
        /// migration-scan:ignore-file uiscreen-main
        """
        #expect(ruleIDs(in: source) == ["uiapplication-key-window"])
    }

    @Test("Invalid directives are reported and suppress nothing", arguments: [
        "// migration-scan:ignore uiscreen-mian",
        "// migration-scan:ignore",
        "// migration-scan:ignore -- no rule before the reason",
        "// migration-scan:disable uiscreen-main",
        "// migration-scan:"
    ])
    func invalid(directive: String) {
        let report = ProjectScanner().scan(source: directive + "\nlet a = UIScreen.main")
        #expect(report.findings.map(\.ruleID) == ["uiscreen-main"])
        #expect(report.notices.map(\.kind) == [.invalidDirective])
        #expect(report.notices.first?.line == 1)
    }

    @Test("Ordinary comments that mention the tool are not directives")
    func ordinaryComments() {
        let report = ProjectScanner().scan(source: "// See migration-scan:ignore in the docs.\nlet a = 1")
        #expect(report.notices.isEmpty)
    }
}
