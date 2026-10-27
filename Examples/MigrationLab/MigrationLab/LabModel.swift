import MigrationScanner
import Observation
import UIKit

/// The screens of the lab, in tab order.
enum LabScreen: String, CaseIterable {
    case scanner, rules, glass, scene

    var title: String {
        switch self {
        case .scanner: "Scanner"
        case .rules: "Rules"
        case .glass: "Liquid Glass"
        case .scene: "Scene"
        }
    }

    var systemImage: String {
        switch self {
        case .scanner: "doc.text.magnifyingglass"
        case .rules: "list.bullet.rectangle"
        case .glass: "circle.hexagongrid"
        case .scene: "macwindow"
        }
    }
}

/// What the scene shows about itself: the replacements for `UIScreen.main`,
/// `UIApplication.shared.windows` and `UIWindowScene.interfaceOrientation`.
struct SceneSnapshot: Equatable {
    var role = ""
    var orientation = ""
    var isOrientationLocked = false
    var displayScale = 0.0
    var windowCount = 0
    var connectedScenes = 0
}

/// The state of one window scene. Each scene creates its own model, so two windows on iPad can
/// show different screens.
@MainActor
@Observable
final class LabModel {
    var selectedScreen: LabScreen
    var source = LegacySample.source
    /// The navigation stack of the rules tab; a deep link pushes a rule onto it.
    var rulePath: [String] = []
    var scene = SceneSnapshot()
    var activations = 0

    /// The launch arguments `-screen <name>` and `-rule <rule-id>` select a tab or open a rule,
    /// as the screenshot script does.
    init(arguments: [String]) {
        func value(after flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
            return arguments[index + 1]
        }
        selectedScreen = value(after: "-screen").flatMap(LabScreen.init(rawValue:)) ?? .scanner
        if let rule = value(after: "-rule"), let url = URL(string: "migrationlab://rule/" + rule) {
            open(url)
        }
    }

    /// The findings for the text in the editor; the scanner is fast enough to run on each change.
    var report: ScanReport {
        ProjectScanner().scan(source: source, file: "Sample.swift")
    }

    /// Opens `migrationlab://rule/<rule-id>`. Anything else, including an unknown rule, is ignored.
    func open(_ url: URL) {
        guard url.scheme == "migrationlab", url.host() == "rule" else { return }
        let id = url.lastPathComponent
        guard RuleCatalog.rule(id: id) != nil else { return }
        rulePath = [id]
        selectedScreen = .rules
    }

    func sceneDidChange(_ windowScene: UIWindowScene) {
        let geometry = windowScene.effectiveGeometry
        scene = SceneSnapshot(
            role: windowScene.session.role.rawValue,
            orientation: Self.name(of: geometry.interfaceOrientation),
            isOrientationLocked: geometry.isInterfaceOrientationLocked,
            displayScale: windowScene.traitCollection.displayScale,
            windowCount: windowScene.windows.count,
            connectedScenes: UIApplication.shared.connectedScenes.count
        )
    }

    private static func name(of orientation: UIInterfaceOrientation) -> String {
        switch orientation {
        case .portrait: "Portrait"
        case .portraitUpsideDown: "Portrait upside down"
        case .landscapeLeft: "Landscape left"
        case .landscapeRight: "Landscape right"
        default: "Unknown"
        }
    }
}
