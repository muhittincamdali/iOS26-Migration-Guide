import Testing
@testable import MigrationScanner

@Suite("Matchers")
struct MatcherTests {
    @Test("onChange: closures with one parameter are the deprecated overload", arguments: [
        "x.onChange(of: value) { newValue in }",
        "x.onChange(of: value) { _ in }",
        "x.onChange(of: value) { (newValue) in }",
        "x.onChange(of: value) { (newValue: Int) in }",
        "x.onChange(of: value) { [weak self] newValue in self?.use(newValue) }",
        "x.onChange(of: value) { print($0) }",
        "x.onChange(of: value, perform: handle)",
        "x.onChange(of: value, perform: { _ in })"
    ])
    func onChangeDeprecated(source: String) {
        #expect(findings(of: "on-change-single-parameter", in: source).count == 1)
    }

    @Test("onChange: closures with zero or two parameters are current", arguments: [
        "x.onChange(of: value) { }",
        "x.onChange(of: value) { reload() }",
        "x.onChange(of: value) { old, new in }",
        "x.onChange(of: value) { (old, new) in }",
        "x.onChange(of: value) { print($0, $1) }",
        "x.onChange(of: value, initial: true) { reload() }",
        "x.onChange(of: value) { items.map { $0 * 2 } }",
        "x.onChange(of: value) { for item in items { use(item) } }",
        "x.onChange(of: value) { let doubled = value * 2; use(doubled) }"
    ])
    func onChangeCurrent(source: String) {
        #expect(findings(of: "on-change-single-parameter", in: source).isEmpty)
    }

    @Test("Declarations match on argument labels, across lines, attributes, defaults and generics")
    func declarationLabels() {
        let source = """
        final class AppDelegate: UIResponder, UIApplicationDelegate {
            @objc
            func application(
                _ app: UIApplication,
                open url: URL,
                options: Dictionary<UIApplication.OpenURLOptionsKey, Any> = [:]
            ) -> Bool { true }

            func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
        }
        """
        let found = findings(of: "app-delegate-open-url", in: source)
        #expect(found.map(\.location) == [SourceLocation(line: 3, column: 10)])
    }

    @Test("Calls to a method with the same name are not declarations")
    func callIsNotDeclaration() {
        #expect(findings(of: "app-delegate-open-url", in: "delegate.application(app, open: url, options: [:])").isEmpty)
        #expect(findings(of: "app-delegate-life-cycle-method", in: "delegate.applicationDidBecomeActive(app)").isEmpty)
    }

    @Test("Call labels: nested parentheses, closures and ternaries do not add labels")
    func callLabels() {
        let tokens = Lexer.lex("f(a: g(b: 1, c: 2), cond ? x : y, { (p: Int) in p }, d: [1, 2])").tokens
        let index = TokenIndex(tokens: tokens)
        #expect(index.arguments(after: 0, declaration: false)?.labels == ["a", "_", "_", "d"])
    }

    @Test("An unclosed call has no argument list")
    func unclosedCall() {
        let arguments = Lexer.lex("f(" + String(repeating: "a, ", count: 10_000)).tokens
        #expect(TokenIndex(tokens: arguments).arguments(after: 0, declaration: false) == nil)
    }

    @Test("Many unclosed or deeply nested calls and closures finish in linear time", .timeLimit(.minutes(1)))
    func pathologicalCalls() {
        let unclosed = String(repeating: "UIWindow(frame: ", count: 100_000)
        #expect(findings(of: "uiwindow-without-scene", in: unclosed).isEmpty)
        let nested = String(repeating: "UIWindow(frame: ", count: 50_000) + "r" + String(repeating: ")", count: 50_000)
        #expect(findings(of: "uiwindow-without-scene", in: nested).count == 50_000)
        let closures = String(repeating: "x.onChange(of: v) { a in ", count: 30_000) + String(repeating: "}", count: 30_000)
        #expect(findings(of: "on-change-single-parameter", in: closures).count == 30_000)
    }

    @Test("Text concatenation is reported at the operator, also across lines")
    func textConcatenation() {
        let source = """
        var body: some View {
            Text("Version ")
                + Text(version).bold()
        }
        """
        #expect(findings(of: "text-concatenation", in: source).map(\.location) == [SourceLocation(line: 3, column: 9)])
    }

    @Test("interfaceOrientation through any geometry value is current")
    func geometryBases() {
        let source = """
        let a = scene.effectiveGeometry.interfaceOrientation
        let b = previousEffectiveGeometry.interfaceOrientation
        let c = self.interfaceOrientation
        """
        #expect(findings(of: "window-scene-interface-orientation", in: source).map(\.location?.line) == [3])
    }

    @Test("Several findings on one line keep their own columns")
    func columns() {
        let report = ProjectScanner().scan(source: "let w = UIWindow(frame: UIScreen.main.bounds)")
        #expect(report.findings.map(\.ruleID) == ["uiwindow-without-scene", "uiscreen-main"])
        #expect(report.findings.map(\.location?.column) == [9, 34])
    }

    @Test("Minimum severity and rule selection filter the report")
    func configurationFilters() {
        let source = "NavigationView { Text(\"a\") }.onChange(of: x) { v in }; let s = UIScreen.main"
        #expect(Set(ruleIDs(in: source)) == ["navigation-view", "on-change-single-parameter", "uiscreen-main"])
        #expect(Set(ruleIDs(in: source, configuration: ScanConfiguration(minimumSeverity: .warning))) == ["on-change-single-parameter", "uiscreen-main"])
        let only = ScanConfiguration(rules: [RuleCatalog.rule(id: "uiscreen-main")!])
        #expect(ruleIDs(in: source, configuration: only) == ["uiscreen-main"])
    }

    @Test("A source over the size limit is skipped with a notice")
    func sourceSizeLimit() {
        let report = ProjectScanner(configuration: ScanConfiguration(maximumFileSize: 10)).scan(source: "let s = UIScreen.main")
        #expect(report.findings.isEmpty)
        #expect(report.notices.map(\.kind) == [.fileTooLarge])
    }
}
