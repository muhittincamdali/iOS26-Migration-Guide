import UIKit

/// The app delegate of a scene-based app keeps only process-wide work. Everything about the
/// window, URLs and foreground/background state lives in ``SceneDelegate``.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }
}
