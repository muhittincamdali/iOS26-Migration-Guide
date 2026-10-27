# Adopting the scene life cycle

Move a UIKit app from the app delegate to a scene delegate before you build it with the iOS 27 SDK.

## Overview

Since iOS 26, UIKit logs a message for apps that have not adopted scenes, and Apple's technote
TN3187 states the consequence: "In the next major release following iOS 26, UIScene lifecycle will
be required when building with the latest SDK; otherwise, your app won't launch." That release is
iOS 27. Only adopting the scene life cycle is required; supporting several scenes at once is
optional.

SwiftUI apps that start with `@main struct MyApp: App` already use scenes. This guide is for apps
whose entry point is a `UIApplicationDelegate`. The scanner reports such an app with
`scene-manifest-missing` or `scene-configuration-missing`, and the app delegate methods that move
with the rules in the scene life cycle category of <doc:RuleReference>.

The code below is from the MigrationLab example app in the repository's `Examples` folder, which
builds in CI.

### Step 1: Add a scene manifest

Add `UIApplicationSceneManifest` to the app's Info.plist with one window scene configuration that
names your scene delegate class:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
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
```

Set `UIApplicationSupportsMultipleScenes` to `false` if your app should keep one window on iPad.
The build setting `INFOPLIST_KEY_UIApplicationSceneManifest_Generation` also creates a manifest,
but without configurations; then return one from
`application(_:configurationForConnecting:options:)` in the app delegate.

### Step 2: Create the window in the scene delegate

The window now belongs to a window scene. Create it with `UIWindow(windowScene:)` when the scene
connects; `UIWindow(frame:)` and `UIWindow()` are deprecated in iOS 26.0.

```swift
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
```

Delete `var window: UIWindow?` and the window code from the app delegate, and replace
`@UIApplicationMain` with `@main`: the attribute is an error in the Swift 6 language mode.

### Step 3: Move the life-cycle methods

UIKit calls these scene delegate methods instead of the app delegate ones. The app delegate
versions are deprecated in iOS 26.0, and in a scene-based app UIKit does not call them.

| App delegate                                         | Scene delegate                                       |
| ---------------------------------------------------- | ---------------------------------------------------- |
| `applicationDidBecomeActive(_:)`                     | `sceneDidBecomeActive(_:)`                           |
| `applicationWillResignActive(_:)`                    | `sceneWillResignActive(_:)`                          |
| `applicationDidEnterBackground(_:)`                  | `sceneDidEnterBackground(_:)`                        |
| `applicationWillEnterForeground(_:)`                 | `sceneWillEnterForeground(_:)`                       |
| `application(_:open:options:)`                       | `scene(_:openURLContexts:)`                          |
| `application(_:continue:restorationHandler:)`        | `scene(_:continue:)`                                 |
| `application(_:performActionFor:completionHandler:)` | `windowScene(_:performActionFor:completionHandler:)` |
| `application(_:userDidAcceptCloudKitShareWith:)`     | `windowScene(_:userDidAcceptCloudKitShareWith:)`     |

What launched the app (a URL, a user activity, a Home Screen quick action, a CloudKit share) no
longer arrives in `launchOptions`; read it from `connectionOptions` in
`scene(_:willConnectTo:options:)`, as step 2 does for URLs. URLs that arrive while the app runs
come to the scene:

```swift
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            model.open(url)
        }
    }
```

Work that belongs to the process, such as configuring analytics or registering for remote
notifications, stays in `application(_:didFinishLaunchingWithOptions:)`.

### Step 4: Replace process-wide window and screen lookups

With scenes, an app can have several windows on several screens, so the shortcuts that assumed
one of each are deprecated:

| Instead of                                                  | Use                                                                                 |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `UIScreen.main` (deprecated in iOS 26.0)                    | `view.window?.windowScene?.screen`, or `traitCollection.displayScale` for the scale |
| `UIApplication.shared.keyWindow`                            | `view.window`, or the window scene's `keyWindow`                                    |
| `UIApplication.shared.windows`                              | the window scene's `windows`                                                        |
| `windowScene.interfaceOrientation` (deprecated in iOS 26.0) | `windowScene.effectiveGeometry.interfaceOrientation`                                |
| `UIApplication.shared.statusBarFrame`                       | `windowScene.statusBarManager?.statusBarFrame`                                      |

The scene delegate hears about geometry changes, such as a rotation or a resized iPad window,
through `windowScene(_:didUpdateEffectiveGeometry:)` (iOS 26):

```swift
    func windowScene(_ windowScene: UIWindowScene, didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry) {
        model.sceneDidChange(windowScene)
    }
```

### Step 5: Check the result

Run the scanner again. When the scene life cycle category is clean, run the app on iPad and try
it in Split View, Slide Over and Stage Manager, as TN3187 recommends.

```sh
migration-scan --only scene-manifest-missing,scene-configuration-missing,app-delegate-life-cycle-method,uiscreen-main MyApp
```

## See Also

- [TN3187: Migrating to the UIKit scene-based life cycle](https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle)
- [UIApplicationSceneManifest](https://developer.apple.com/documentation/bundleresources/information-property-list/uiapplicationscenemanifest)
