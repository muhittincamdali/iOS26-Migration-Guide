import SwiftUI
import UIKit

/// A standard tab bar, so it picks up Liquid Glass without any custom appearance.
final class LabTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let model: LabModel

    init(model: LabModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        tabs = LabScreen.allCases.map { screen in
            UITab(title: screen.title, image: UIImage(systemName: screen.systemImage), identifier: screen.rawValue) { _ in
                UIHostingController(rootView: LabScreenView(screen: screen, model: model))
            }
        }
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("LabTabBarController is created in code")
    }

    /// UIKit tracks the `@Observable` properties read here and calls the method again when they
    /// change, for example when a URL opens the rules tab.
    override func updateProperties() {
        super.updateProperties()
        let identifier = model.selectedScreen.rawValue
        if selectedTab?.identifier != identifier {
            selectedTab = tabs.first { $0.identifier == identifier }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
        if let screen = LabScreen(rawValue: selectedTab.identifier) {
            model.selectedScreen = screen
        }
    }
}

/// Routes a tab to its SwiftUI screen.
struct LabScreenView: View {
    let screen: LabScreen
    @Bindable var model: LabModel
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: screen == .rules ? $model.rulePath : $path) {
            switch screen {
            case .scanner: ScannerScreen(model: model)
            case .rules: RulesScreen(model: model)
            case .glass: GlassScreen()
            case .scene: SceneScreen(model: model)
            }
        }
    }
}
