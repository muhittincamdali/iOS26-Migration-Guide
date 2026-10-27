# Rule reference

All 42 rules, by category, with what to write instead.

## Overview

Errors stop the app from compiling or launching with the current toolchain or SDK. Warnings are
deprecated API that still works, or a setting the latest SDK ignores. Info findings are
soft deprecations (`deprecated: 100000.0` in the SDK, no compiler warning yet) and design review
points. `migration-scan --explain <rule>` prints a rule's full explanation and the SDK declaration
it is based on.

### Scene life cycle

| Rule | Severity | Fix |
| --- | --- | --- |
| `scene-manifest-missing`: The app does not adopt the scene life cycle | error | Add a UIApplicationSceneManifest with a window scene configuration to Info.plist, add a UIWindowSceneDelegate and create the window in scene(\_:willConnectTo:options:). |
| `scene-configuration-missing`: The scene manifest names no scene configuration | error | List a UIWindowSceneSessionRoleApplication configuration with UISceneDelegateClassName in the manifest, or return a UISceneConfiguration from application(\_:configurationForConnecting:options:). |
| `app-delegate-life-cycle-method`: App delegate life-cycle method | warning | Move the code to sceneDidBecomeActive(\_:), sceneWillResignActive(\_:), sceneDidEnterBackground(\_:) or sceneWillEnterForeground(\_:) of the scene delegate, or observe the UIApplication notifications. |
| `app-delegate-open-url`: App delegate opens URLs | warning | Handle URLs in scene(\_:openURLContexts:), and at launch in connectionOptions.urlContexts of scene(\_:willConnectTo:options:). |
| `app-delegate-user-activity`: App delegate continues user activities | warning | Implement scene(\_:continue:), scene(\_:willContinueUserActivityWithType:), scene(\_:didFailToContinueUserActivityWithType:error:) and scene(\_:didUpdate:) in the scene delegate; at launch read connectionOptions.userActivities. |
| `app-delegate-shortcut-item`: App delegate handles Home Screen quick actions | warning | Implement windowScene(\_:performActionFor:completionHandler:) in the scene delegate; at launch read connectionOptions.shortcutItem. |
| `app-delegate-cloudkit-share`: App delegate accepts CloudKit shares | warning | Implement windowScene(\_:userDidAcceptCloudKitShareWith:) in the scene delegate; at launch read connectionOptions.cloudKitShareMetadata. |
| `app-delegate-orientation-mask`: App delegate decides supported orientations | warning | Return the orientations from the window scene delegate's supportedInterfaceOrientations(for:), or from the view controllers' supportedInterfaceOrientations. |
| `launch-options-key`: Launch options read in the app delegate | warning | Read connectionOptions.urlContexts, .userActivities, .shortcutItem, .cloudKitShareMetadata or .sourceApplication in scene(\_:willConnectTo:options:). |
| `open-url-options-key`: UIApplication.OpenURLOptionsKey | warning | Read UISceneOpenURLOptions from each UIOpenURLContext in scene(\_:openURLContexts:). |
| `uiwindow-without-scene`: UIWindow created without a scene | warning | Create the window with UIWindow(windowScene:) in scene(\_:willConnectTo:options:). |
| `uiapplication-key-window`: UIApplication.shared.keyWindow | warning | Use view.window, or the keyWindow of the relevant UIWindowScene. |
| `uiapplication-windows`: UIApplication.shared.windows | warning | Use the windows of the relevant UIWindowScene (view.window?.windowScene?.windows). |
| `uiscreen-main`: UIScreen.main | warning | Use view.window?.windowScene?.screen, or a trait such as traitCollection.displayScale for the scale. |

### UIKit

| Rule | Severity | Fix |
| --- | --- | --- |
| `window-scene-interface-orientation`: UIWindowScene.interfaceOrientation | warning | Read windowScene.effectiveGeometry.interfaceOrientation. |
| `uiscreen-display-link`: UIScreen.displayLink(withTarget:selector:) | warning | Create the display link from the window scene (the equivalent API on UIWindowScene), or with CADisplayLink(target:selector:). |
| `can-open-url`: UIApplication.canOpenURL(\_:) | warning | Call open(\_:options:completionHandler:) (or the async open(\_:options:)) and handle a false result. |
| `open-url-synchronous`: UIApplication.openURL(\_:) | error | Call open(\_:options:completionHandler:) or the async open(\_:options:). |
| `status-bar-application-property`: Status bar read from UIApplication | warning | Use view.window?.windowScene?.statusBarManager, or override preferredStatusBarStyle and prefersStatusBarHidden in the view controller. |
| `application-icon-badge-number`: UIApplication.applicationIconBadgeNumber | warning | Call UNUserNotificationCenter.current().setBadgeCount(\_:). |
| `bar-button-style-done`: UIBarButtonItem.Style.done | warning | Use style: .prominent. |
| `done-button-appearance`: doneButtonAppearance | warning | Use prominentButtonAppearance. |
| `search-bar-placement-inline`: Search bar placement .inline | warning | Use .integrated. |
| `menu-identifier-new-scene`: UIMenu.Identifier.newScene | warning | Use .newItem. |

### Liquid Glass

| Rule | Severity | Fix |
| --- | --- | --- |
| `design-compatibility-mode`: UIDesignRequiresCompatibility is set | warning | Remove the key (or INFOPLIST\_KEY\_UIDesignRequiresCompatibility) and fix the screens that look wrong with the current design. |
| `custom-bar-background`: Custom bar background | info | Remove the custom background and let the system choose it; keep it only where the design needs it and check the result on iOS 26. |

### SwiftUI

| Rule | Severity | Fix |
| --- | --- | --- |
| `text-concatenation`: Text + Text | warning | Interpolate instead: Text("\\(Text("Total").bold()) \\(amount)"). |
| `on-change-single-parameter`: onChange(of:perform:) | warning | Use onChange(of:initial:\_:) with a closure that takes no parameters or two (oldValue, newValue). |
| `navigation-link-is-active`: NavigationLink(isActive:) and NavigationLink(tag:selection:) | warning | Use NavigationLink(value:label:) with navigationDestination(for:destination:), or navigationDestination(isPresented:destination:), inside a NavigationStack. |
| `navigation-view`: NavigationView | info | Use NavigationStack, or NavigationSplitView for multiple columns. |
| `navigation-bar-title`: .navigationBarTitle | info | Use .navigationTitle(\_:), with .navigationBarTitleDisplayMode(\_:) for the display mode. |
| `foreground-color`: .foregroundColor | info | Use .foregroundStyle(\_:). |
| `corner-radius-modifier`: .cornerRadius | info | Use .clipShape(.rect(cornerRadius:)), or fill a RoundedRectangle. |
| `navigation-bar-items`: .navigationBarItems | info | Use .toolbar with ToolbarItem(placement: .topBarLeading) and .topBarTrailing. |
| `edges-ignoring-safe-area`: .edgesIgnoringSafeArea | info | Use .ignoresSafeArea(\_:edges:). |
| `action-sheet`: .actionSheet | info | Use .confirmationDialog(\_:isPresented:titleVisibility:actions:). |
| `alert-content-closure`: .alert(isPresented:content:) | info | Use .alert(\_:isPresented:actions:message:) with Button actions. |
| `accent-color-modifier`: .accentColor | info | Use .tint(\_:), or the asset catalog's accent color. |
| `autocapitalization-modifier`: .autocapitalization | info | Use .textInputAutocapitalization(\_:). |
| `disable-autocorrection`: .disableAutocorrection | info | Use .autocorrectionDisabled(\_:). |
| `navigation-bar-hidden`: .navigationBarHidden | info | Use .toolbar(.hidden, for: .navigationBar). |

### Swift language

| Rule | Severity | Fix |
| --- | --- | --- |
| `ui-application-main-attribute`: @UIApplicationMain and @NSApplicationMain are errors in Swift 6 | error | Write @main on the app delegate class instead. |
