import Testing
@testable import MigrationScanner

/// One source that a rule must report and one it must leave alone.
struct RuleSample: CustomTestStringConvertible, Sendable {
    let ruleID: String
    let reported: String
    let ignored: String

    var testDescription: String { ruleID }
}

/// Every source rule appears here; `catalogIsCovered` fails when a rule is added without samples.
let ruleSamples: [RuleSample] = [
    RuleSample(ruleID: "app-delegate-life-cycle-method",
               reported: "func applicationWillEnterForeground(_ application: UIApplication) {}",
               ignored: "func sceneWillEnterForeground(_ scene: UIScene) {}"),
    RuleSample(ruleID: "app-delegate-open-url",
               reported: "func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool { true }",
               ignored: "func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {}"),
    RuleSample(ruleID: "app-delegate-user-activity",
               reported: "func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void) -> Bool { true }",
               ignored: "func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {}"),
    RuleSample(ruleID: "app-delegate-shortcut-item",
               reported: "func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool { true }",
               ignored: "func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool { true }"),
    RuleSample(ruleID: "app-delegate-cloudkit-share",
               reported: "func application(_ application: UIApplication, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {}",
               ignored: "func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {}"),
    RuleSample(ruleID: "app-delegate-orientation-mask",
               reported: "func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask { .all }",
               ignored: "override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }"),
    RuleSample(ruleID: "launch-options-key",
               reported: "let url = launchOptions?[UIApplication.LaunchOptionsKey.url]",
               ignored: "let contexts = connectionOptions.urlContexts"),
    RuleSample(ruleID: "open-url-options-key",
               reported: "let options: [UIApplication.OpenURLOptionsKey: Any] = [:]",
               ignored: "let options = UIApplication.OpenExternalURLOptionsKey.universalLinksOnly"),
    RuleSample(ruleID: "uiwindow-without-scene",
               reported: "let window = UIWindow(frame: UIScreen.main.bounds)",
               ignored: "let window = UIWindow(windowScene: windowScene)"),
    RuleSample(ruleID: "uiapplication-key-window",
               reported: "let window = UIApplication.shared.keyWindow",
               ignored: "let window = windowScene.keyWindow"),
    RuleSample(ruleID: "uiapplication-windows",
               reported: "let first = UIApplication.shared.windows.first",
               ignored: "let first = windowScene.windows.first"),
    RuleSample(ruleID: "uiscreen-main",
               reported: "let scale = UIScreen.main.scale",
               ignored: "let scale = view.window?.windowScene?.screen.scale // not UIScreen.main"),
    RuleSample(ruleID: "window-scene-interface-orientation",
               reported: "let orientation = windowScene.interfaceOrientation",
               ignored: "let orientation = windowScene.effectiveGeometry.interfaceOrientation"),
    RuleSample(ruleID: "uiscreen-display-link",
               reported: "let link = screen.displayLink(withTarget: self, selector: #selector(step))",
               ignored: "let link = CADisplayLink(target: self, selector: #selector(step))"),
    RuleSample(ruleID: "can-open-url",
               reported: "if UIApplication.shared.canOpenURL(url) { }",
               ignored: "await UIApplication.shared.open(url)"),
    RuleSample(ruleID: "open-url-synchronous",
               reported: "UIApplication.shared.openURL(url)",
               ignored: "@Environment(\\.openURL) private var openURL; func go() { openURL(url) }"),
    RuleSample(ruleID: "status-bar-application-property",
               reported: "let height = UIApplication.shared.statusBarFrame.height",
               ignored: "let height = windowScene.statusBarManager?.statusBarFrame.height"),
    RuleSample(ruleID: "application-icon-badge-number",
               reported: "UIApplication.shared.applicationIconBadgeNumber = 0",
               ignored: "try await UNUserNotificationCenter.current().setBadgeCount(0)"),
    RuleSample(ruleID: "bar-button-style-done",
               reported: "let item = UIBarButtonItem(title: \"Save\", style: .done, target: nil, action: nil)",
               ignored: "let item = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)"),
    RuleSample(ruleID: "done-button-appearance",
               reported: "appearance.doneButtonAppearance = buttons",
               ignored: "appearance.prominentButtonAppearance = buttons"),
    RuleSample(ruleID: "search-bar-placement-inline",
               reported: "navigationItem.preferredSearchBarPlacement = .inline",
               ignored: "navigationItem.preferredSearchBarPlacement = .integrated"),
    RuleSample(ruleID: "menu-identifier-new-scene",
               reported: "builder.remove(menu: .newScene)",
               ignored: "builder.remove(menu: .newItem)"),
    RuleSample(ruleID: "custom-bar-background",
               reported: "appearance.configureWithOpaqueBackground()",
               ignored: "appearance.configureWithDefaultBackground()"),
    RuleSample(ruleID: "text-concatenation",
               reported: "let label = Text(\"Total: \")\n    + Text(amount).bold()",
               ignored: "let label = Text(\"Total: \\(Text(amount).bold())\"); let n = count + 1"),
    RuleSample(ruleID: "on-change-single-parameter",
               reported: "content.onChange(of: query) { newValue in search(newValue) }",
               ignored: "content.onChange(of: query) { oldValue, newValue in search(newValue) }"),
    RuleSample(ruleID: "navigation-link-is-active",
               reported: "NavigationLink(destination: DetailView(), isActive: $showsDetail) { Text(\"Open\") }",
               ignored: "NavigationLink(value: item) { Text(item.name) }"),
    RuleSample(ruleID: "navigation-view",
               reported: "NavigationView { List {} }",
               ignored: "NavigationStack { List {} }"),
    RuleSample(ruleID: "navigation-bar-title",
               reported: "list.navigationBarTitle(\"Inbox\")",
               ignored: "list.navigationTitle(\"Inbox\")"),
    RuleSample(ruleID: "foreground-color",
               reported: "Text(\"Hi\").foregroundColor(.red)",
               ignored: "Text(\"Hi\").foregroundStyle(.red)"),
    RuleSample(ruleID: "corner-radius-modifier",
               reported: "image.cornerRadius(8)",
               ignored: "image.clipShape(.rect(cornerRadius: 8)); view.layer.cornerRadius = 8"),
    RuleSample(ruleID: "navigation-bar-items",
               reported: "list.navigationBarItems(trailing: addButton)",
               ignored: "list.toolbar { ToolbarItem(placement: .topBarTrailing) { addButton } }"),
    RuleSample(ruleID: "edges-ignoring-safe-area",
               reported: "color.edgesIgnoringSafeArea(.all)",
               ignored: "color.ignoresSafeArea()"),
    RuleSample(ruleID: "action-sheet",
               reported: "view.actionSheet(isPresented: $asks) { ActionSheet(title: Text(\"Delete?\")) }",
               ignored: "view.confirmationDialog(\"Delete?\", isPresented: $asks) { Button(\"Delete\") {} }"),
    RuleSample(ruleID: "alert-content-closure",
               reported: "view.alert(isPresented: $fails) { Alert(title: Text(\"Failed\")) }",
               ignored: "view.alert(\"Failed\", isPresented: $fails) {}; view.alert(isPresented: $fails, error: error) { _ in }"),
    RuleSample(ruleID: "accent-color-modifier",
               reported: "content.accentColor(.orange)",
               ignored: "content.tint(.orange)"),
    RuleSample(ruleID: "autocapitalization-modifier",
               reported: "field.autocapitalization(.none)",
               ignored: "field.textInputAutocapitalization(.never)"),
    RuleSample(ruleID: "disable-autocorrection",
               reported: "field.disableAutocorrection(true)",
               ignored: "field.autocorrectionDisabled()"),
    RuleSample(ruleID: "navigation-bar-hidden",
               reported: "content.navigationBarHidden(true)",
               ignored: "content.toolbar(.hidden, for: .navigationBar)"),
    RuleSample(ruleID: "ui-application-main-attribute",
               reported: "@UIApplicationMain\nfinal class AppDelegate: UIResponder, UIApplicationDelegate {}",
               ignored: "@main\nfinal class AppDelegate: UIResponder, UIApplicationDelegate {}")
]

@Suite("Rule samples")
struct RuleSampleTests {
    @Test("Every source rule has samples")
    func catalogIsCovered() {
        let sourceRules = Set(RuleCatalog.all.filter(\.isSourceRule).map(\.id))
        #expect(Set(ruleSamples.map(\.ruleID)) == sourceRules)
    }

    @Test("The rule reports its sample", arguments: ruleSamples)
    func reports(sample: RuleSample) {
        #expect(findings(of: sample.ruleID, in: sample.reported).count == 1)
    }

    @Test("The rule ignores the replacement", arguments: ruleSamples)
    func ignores(sample: RuleSample) {
        #expect(findings(of: sample.ruleID, in: sample.ignored).isEmpty)
    }

    @Test("A sample inside a comment or a string is ignored", arguments: ruleSamples)
    func ignoresNonCode(sample: RuleSample) {
        let inComment = sample.reported.split(separator: "\n").map { "// " + $0 }.joined(separator: "\n")
        let inString = "let text = \"\"\"\n\(sample.reported.replacingOccurrences(of: "\\", with: "\\\\"))\n\"\"\""
        #expect(findings(of: sample.ruleID, in: inComment).isEmpty)
        #expect(findings(of: sample.ruleID, in: inString).isEmpty)
    }
}
