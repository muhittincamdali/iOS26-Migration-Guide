import UIKit

final class InboxViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inbox"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(close)
        )
        navigationItem.preferredSearchBarPlacement = .inline

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationItem.standardAppearance = appearance
    }

    @objc private func close() {
        let width = UIScreen.main.bounds.width // "UIScreen.main" in a string is not code
        print(width)
        if let settings = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settings) {
            UIApplication.shared.openURL(settings)
        }
    }
}
