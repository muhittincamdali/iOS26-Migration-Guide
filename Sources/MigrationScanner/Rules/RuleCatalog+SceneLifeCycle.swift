extension RuleCatalog {
    private static let technote = "https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle"
    private static let movedToScenes = "UIKit does not call this app delegate method in an app that uses scenes, and the compiler does not warn about implementing it."

    static let sceneLifeCycleRules: [Rule] = [
        Rule(
            id: "scene-manifest-missing",
            title: "The app does not adopt the scene life cycle",
            severity: .error,
            category: .sceneLifeCycle,
            message: "This UIKit app has no UIApplicationSceneManifest. Built with the iOS 27 SDK, an app without the scene life cycle does not launch.",
            replacement: "Add a UIApplicationSceneManifest with a window scene configuration to Info.plist, add a UIWindowSceneDelegate and create the window in scene(_:willConnectTo:options:).",
            evidence: "TN3187: \"In the next major release following iOS 26, UIScene lifecycle will be required when building with the latest SDK; otherwise, your app won't launch.\"",
            documentation: technote,
            matcher: .project(.sceneManifestMissing)
        ),
        Rule(
            id: "scene-configuration-missing",
            title: "The scene manifest names no scene configuration",
            severity: .error,
            category: .sceneLifeCycle,
            message: "Info.plist has a UIApplicationSceneManifest without UISceneConfigurations, and the app delegate does not implement application(_:configurationForConnecting:options:), so UIKit has no scene delegate to connect.",
            replacement: "List a UIWindowSceneSessionRoleApplication configuration with UISceneDelegateClassName in the manifest, or return a UISceneConfiguration from application(_:configurationForConnecting:options:).",
            evidence: "TN3187 lists both conditions as signs that an app has not adopted scenes",
            documentation: technote,
            matcher: .project(.sceneConfigurationMissing)
        ),
        Rule(
            id: "app-delegate-life-cycle-method",
            title: "App delegate life-cycle method",
            severity: .warning,
            category: .sceneLifeCycle,
            message: movedToScenes + " Deprecated in iOS 26.0.",
            replacement: "Move the code to sceneDidBecomeActive(_:), sceneWillResignActive(_:), sceneDidEnterBackground(_:) or sceneWillEnterForeground(_:) of the scene delegate, or observe the UIApplication notifications.",
            evidence: "UIApplication.h: applicationDidBecomeActive: … API_DEPRECATED(…, ios(2.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscenedelegate/scenedidbecomeactive(_:)",
            matcher: .any([
                .declaration("applicationDidBecomeActive", labels: nil),
                .declaration("applicationWillResignActive", labels: nil),
                .declaration("applicationDidEnterBackground", labels: nil),
                .declaration("applicationWillEnterForeground", labels: nil)
            ])
        ),
        Rule(
            id: "app-delegate-open-url",
            title: "App delegate opens URLs",
            severity: .warning,
            category: .sceneLifeCycle,
            message: movedToScenes + " application(_:open:options:) is deprecated in iOS 26.0.",
            replacement: "Handle URLs in scene(_:openURLContexts:), and at launch in connectionOptions.urlContexts of scene(_:willConnectTo:options:).",
            evidence: "UIApplication.h: application:openURL:options: … API_DEPRECATED(…, ios(9.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscenedelegate/scene(_:openurlcontexts:)",
            matcher: .declaration("application", labels: ["_", "open", "options"])
        ),
        Rule(
            id: "app-delegate-user-activity",
            title: "App delegate continues user activities",
            severity: .warning,
            category: .sceneLifeCycle,
            message: movedToScenes + " The user activity methods are deprecated in iOS 26.0.",
            replacement: "Implement scene(_:continue:), scene(_:willContinueUserActivityWithType:), scene(_:didFailToContinueUserActivityWithType:error:) and scene(_:didUpdate:) in the scene delegate; at launch read connectionOptions.userActivities.",
            evidence: "UIApplication.h: application:continueUserActivity:restorationHandler: … API_DEPRECATED(…, ios(8.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscenedelegate/scene(_:continue:)",
            matcher: .any([
                .declaration("application", labels: ["_", "continue", "restorationHandler"]),
                .declaration("application", labels: ["_", "willContinueUserActivityWithType"]),
                .declaration("application", labels: ["_", "didFailToContinueUserActivityWithType", "error"]),
                .declaration("application", labels: ["_", "didUpdate"])
            ])
        ),
        Rule(
            id: "app-delegate-shortcut-item",
            title: "App delegate handles Home Screen quick actions",
            severity: .warning,
            category: .sceneLifeCycle,
            message: movedToScenes + " application(_:performActionFor:completionHandler:) is deprecated in iOS 26.0.",
            replacement: "Implement windowScene(_:performActionFor:completionHandler:) in the scene delegate; at launch read connectionOptions.shortcutItem.",
            evidence: "UIApplication.h: application:performActionForShortcutItem:completionHandler: … API_DEPRECATED(…, ios(9.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscenedelegate/windowscene(_:performactionfor:completionhandler:)",
            matcher: .any([
                .declaration("application", labels: ["_", "performActionFor", "completionHandler"]),
                .declaration("application", labels: ["_", "performActionFor"])
            ])
        ),
        Rule(
            id: "app-delegate-cloudkit-share",
            title: "App delegate accepts CloudKit shares",
            severity: .warning,
            category: .sceneLifeCycle,
            message: movedToScenes + " application(_:userDidAcceptCloudKitShareWith:) is deprecated in iOS 26.0.",
            replacement: "Implement windowScene(_:userDidAcceptCloudKitShareWith:) in the scene delegate; at launch read connectionOptions.cloudKitShareMetadata.",
            evidence: "UIApplication.h: application:userDidAcceptCloudKitShareWithMetadata: … API_DEPRECATED(…, ios(10.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscenedelegate/windowscene(_:userdidacceptcloudkitsharewith:)",
            matcher: .declaration("application", labels: ["_", "userDidAcceptCloudKitShareWith"])
        ),
        Rule(
            id: "app-delegate-orientation-mask",
            title: "App delegate decides supported orientations",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "application(_:supportedInterfaceOrientationsFor:) and UIApplication.supportedInterfaceOrientations(for:) are deprecated in iOS 27.0.",
            replacement: "Return the orientations from the window scene delegate's supportedInterfaceOrientations(for:), or from the view controllers' supportedInterfaceOrientations.",
            evidence: "UIApplication.h: application:supportedInterfaceOrientationsForWindow: … API_DEPRECATED(…, ios(6.0, 27.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscenedelegate",
            matcher: .any([
                .declaration("application", labels: ["_", "supportedInterfaceOrientationsFor"]),
                .call("supportedInterfaceOrientations", member: true, labels: .exactly(["for"]))
            ])
        ),
        Rule(
            id: "launch-options-key",
            title: "Launch options read in the app delegate",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "With scenes, the URL, user activity, quick action and CloudKit share that launched the app arrive in the scene's connection options, not in launchOptions. These keys are deprecated in iOS 26.0.",
            replacement: "Read connectionOptions.urlContexts, .userActivities, .shortcutItem, .cloudKitShareMetadata or .sourceApplication in scene(_:willConnectTo:options:).",
            evidence: "UIApplication.h: UIApplicationLaunchOptionsURLKey … API_DEPRECATED(…, ios(3.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscene/connectionoptions",
            matcher: .sequences(
                ["url", "sourceApplication", "shortcutItem", "userActivityDictionary", "userActivityType", "cloudKitShareMetadata", "eventAttribution"].map {
                    Pattern([.identifier("LaunchOptionsKey"), .punctuation("."), .identifier($0)], reporting: 2)
                }
            )
        ),
        Rule(
            id: "open-url-options-key",
            title: "UIApplication.OpenURLOptionsKey",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "The open-URL options dictionary belongs to the deprecated app delegate method; deprecated in iOS 26.0.",
            replacement: "Read UISceneOpenURLOptions from each UIOpenURLContext in scene(_:openURLContexts:).",
            evidence: "UIApplication.h: typedef UIApplicationOpenURLOptionsKey … API_DEPRECATED(…, ios(9.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscene/openurloptions",
            matcher: .sequences([Pattern([.identifier("OpenURLOptionsKey")])])
        ),
        Rule(
            id: "uiwindow-without-scene",
            title: "UIWindow created without a scene",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "UIWindow(frame:) and UIWindow() are deprecated in iOS 26.0: a window that is not attached to a window scene is not shown in a scene-based app.",
            replacement: "Create the window with UIWindow(windowScene:) in scene(_:willConnectTo:options:).",
            evidence: "UIWindow.h: initWithFrame: and init … API_DEPRECATED(\"Use init(windowScene:) instead.\", ios(2.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindow/init(windowscene:)",
            matcher: .any([
                .call("UIWindow", member: false, labels: .startingWith(["frame"])),
                .call("UIWindow", member: false, labels: .exactly([]))
            ])
        ),
        Rule(
            id: "uiapplication-key-window",
            title: "UIApplication.shared.keyWindow",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "keyWindow returns a key window across all connected scenes, which is wrong once the app has more than one; deprecated in iOS 13.0.",
            replacement: "Use view.window, or the keyWindow of the relevant UIWindowScene.",
            evidence: "UIApplication.h: keyWindow … API_DEPRECATED(…, ios(2.0, 13.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscene/keywindow",
            matcher: .path("shared", "keyWindow")
        ),
        Rule(
            id: "uiapplication-windows",
            title: "UIApplication.shared.windows",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "UIApplication.windows mixes the windows of every scene; deprecated in iOS 15.0.",
            replacement: "Use the windows of the relevant UIWindowScene (view.window?.windowScene?.windows).",
            evidence: "UIApplication.h: windows … API_DEPRECATED(\"Use UIWindowScene.windows on a relevant window scene instead\", ios(2.0, 15.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscene/windows",
            matcher: .path("shared", "windows")
        ),
        Rule(
            id: "uiscreen-main",
            title: "UIScreen.main",
            severity: .warning,
            category: .sceneLifeCycle,
            message: "With scenes and external displays an app can be on more than one screen, so there is no single main screen; deprecated in iOS 26.0.",
            replacement: "Use view.window?.windowScene?.screen, or a trait such as traitCollection.displayScale for the scale.",
            evidence: "UIScreen.h: mainScreen … API_DEPRECATED(…, ios(2.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiscreen/main",
            matcher: .path("UIScreen", "main")
        )
    ]
}
