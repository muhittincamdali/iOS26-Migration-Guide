import UIKit

/// The scene life cycle that the iOS 27 SDK requires: Info.plist names this class in its
/// `UIApplicationSceneManifest`, and each window scene gets its own window, model and URLs.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let model = LabModel(arguments: ProcessInfo.processInfo.arguments)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LabTabBarController(model: model)
        self.window = window
        window.makeKeyAndVisible()

        model.sceneDidChange(windowScene)
        // A URL that launched the app arrives here, not in the app delegate's launch options.
        if let url = connectionOptions.urlContexts.first?.url {
            model.open(url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            model.open(url)
        }
    }

    func windowScene(_ windowScene: UIWindowScene, didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry) {
        model.sceneDidChange(windowScene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        model.activations += 1
    }
}
