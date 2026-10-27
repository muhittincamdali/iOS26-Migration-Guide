extension RuleCatalog {
    static let uiKitRules: [Rule] = [
        Rule(
            id: "window-scene-interface-orientation",
            title: "UIWindowScene.interfaceOrientation",
            severity: .warning,
            category: .uiKit,
            message: "The window scene's interfaceOrientation is deprecated in iOS 26.0; its geometry now carries the orientation.",
            replacement: "Read windowScene.effectiveGeometry.interfaceOrientation.",
            evidence: "UIWindowScene.h: interfaceOrientation … API_DEPRECATED(\"Use effectiveGeometry.interfaceOrientation instead.\", ios(13.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscene/effectivegeometry",
            matcher: .member("interfaceOrientation", excludedBases: ["Geometry"])
        ),
        Rule(
            id: "uiscreen-display-link",
            title: "UIScreen.displayLink(withTarget:selector:)",
            severity: .warning,
            category: .uiKit,
            message: "Creating a display link from a screen is deprecated in iOS 27.0.",
            replacement: "Create the display link from the window scene (the equivalent API on UIWindowScene), or with CADisplayLink(target:selector:).",
            evidence: "UIScreen.h: displayLinkWithTarget:selector: … API_DEPRECATED(\"Use the equivalent display link API on UIWindowScene\", ios(4.0, 27.0))",
            documentation: "https://developer.apple.com/documentation/quartzcore/cadisplaylink",
            matcher: .call("displayLink", member: true, labels: .startingWith(["withTarget"]))
        ),
        Rule(
            id: "can-open-url",
            title: "UIApplication.canOpenURL(_:)",
            severity: .warning,
            category: .uiKit,
            message: "canOpenURL(_:) is deprecated in iOS 27.0: Apple now recommends opening the URL and handling the failure.",
            replacement: "Call open(_:options:completionHandler:) (or the async open(_:options:)) and handle a false result.",
            evidence: "UIApplication.h: canOpenURL: … API_DEPRECATED(\"Prefer attempting to open URLs and handling any failures\", ios(3.0, 27.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiapplication/open(_:options:completionhandler:)",
            matcher: .call("canOpenURL", member: true, labels: .any)
        ),
        Rule(
            id: "open-url-synchronous",
            title: "UIApplication.openURL(_:)",
            severity: .error,
            category: .uiKit,
            message: "The synchronous openURL(_:) has been deprecated since iOS 10.0, and Apple's documentation now states that calling it has no effect: the URL does not open.",
            replacement: "Call open(_:options:completionHandler:) or the async open(_:options:).",
            evidence: "UIApplication.h: openURL: … API_DEPRECATED_WITH_REPLACEMENT(\"openURL:options:completionHandler:\", ios(2.0, 10.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiapplication/open(_:options:completionhandler:)",
            matcher: .sequences([Pattern([.identifier("shared"), .punctuation("."), .identifier("openURL"), .punctuation("(")], reporting: 2)])
        ),
        Rule(
            id: "status-bar-application-property",
            title: "Status bar read from UIApplication",
            severity: .warning,
            category: .uiKit,
            message: "The status bar belongs to a window scene; UIApplication's status bar properties are deprecated in iOS 13.0.",
            replacement: "Use view.window?.windowScene?.statusBarManager, or override preferredStatusBarStyle and prefersStatusBarHidden in the view controller.",
            evidence: "UIApplication.h: statusBarFrame, statusBarStyle, statusBarHidden, statusBarOrientation … API_DEPRECATED(…, ios(2.0, 13.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uiwindowscene/statusbarmanager",
            matcher: .sequences(
                ["statusBarFrame", "statusBarStyle", "isStatusBarHidden", "statusBarOrientation"].map {
                    Pattern([.identifier("shared"), .punctuation("."), .identifier($0)], reporting: 2)
                }
            )
        ),
        Rule(
            id: "application-icon-badge-number",
            title: "UIApplication.applicationIconBadgeNumber",
            severity: .warning,
            category: .uiKit,
            message: "Setting the badge through UIApplication is deprecated in iOS 17.0.",
            replacement: "Call UNUserNotificationCenter.current().setBadgeCount(_:).",
            evidence: "UIApplication.h: applicationIconBadgeNumber … API_DEPRECATED(…, ios(2.0, 17.0))",
            documentation: "https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/setbadgecount(_:withcompletionhandler:)",
            matcher: .member("applicationIconBadgeNumber", excludedBases: [])
        ),
        Rule(
            id: "bar-button-style-done",
            title: "UIBarButtonItem.Style.done",
            severity: .warning,
            category: .uiKit,
            message: "The done style is renamed to prominent in iOS 26.0, where prominent bar buttons get the tinted Liquid Glass look.",
            replacement: "Use style: .prominent.",
            evidence: "UIBarButtonItem.h: UIBarButtonItemStyleDone API_DEPRECATED_WITH_REPLACEMENT(\"UIBarButtonItemStyleProminent\", ios(2.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uibarbuttonitem/style-swift.enum/prominent",
            matcher: .sequences([
                Pattern([.identifier("style"), .punctuation(":"), .punctuation("."), .identifier("done")], reporting: 3),
                Pattern([.identifier("Style"), .punctuation("."), .identifier("done")], reporting: 2)
            ])
        ),
        Rule(
            id: "done-button-appearance",
            title: "doneButtonAppearance",
            severity: .warning,
            category: .uiKit,
            message: "The navigation bar and toolbar appearance property is renamed in iOS 26.0.",
            replacement: "Use prominentButtonAppearance.",
            evidence: "UINavigationBarAppearance.h, UIToolbarAppearance.h: doneButtonAppearance API_DEPRECATED_WITH_REPLACEMENT(\"prominentButtonAppearance\", ios(13.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uinavigationbarappearance/prominentbuttonappearance",
            matcher: .member("doneButtonAppearance", excludedBases: [])
        ),
        Rule(
            id: "search-bar-placement-inline",
            title: "Search bar placement .inline",
            severity: .warning,
            category: .uiKit,
            message: "UINavigationItem.SearchBarPlacement.inline is renamed in iOS 26.0.",
            replacement: "Use .integrated.",
            evidence: "UINavigationItem.h: UINavigationItemSearchBarPlacementInline API_DEPRECATED_WITH_REPLACEMENT(\"UINavigationItemSearchBarPlacementIntegrated\", ios(16.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uinavigationitem/searchbarplacement-swift.enum/integrated",
            matcher: .sequences([
                Pattern([.identifierEnding("SearchBarPlacement"), .punctuation("="), .punctuation("."), .identifier("inline")], reporting: 3),
                Pattern([.identifier("SearchBarPlacement"), .punctuation("."), .identifier("inline")], reporting: 2)
            ])
        ),
        Rule(
            id: "menu-identifier-new-scene",
            title: "UIMenu.Identifier.newScene",
            severity: .warning,
            category: .uiKit,
            message: "The New Scene menu identifier is renamed in iOS 26.0.",
            replacement: "Use .newItem.",
            evidence: "UIMenu.h: UIMenuNewScene API_DEPRECATED_WITH_REPLACEMENT(\"UIMenuNewItem\", ios(13.0, 26.0))",
            documentation: "https://developer.apple.com/documentation/uikit/uimenu/identifier-swift.struct/newitem",
            matcher: .member("newScene", excludedBases: [])
        )
    ]
}
