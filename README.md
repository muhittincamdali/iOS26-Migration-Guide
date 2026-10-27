<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Latest version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

A command-line tool, a Swift library and a set of guides for moving an iOS app to the iOS 26 and
iOS 27 SDKs. `migration-scan` reads your Swift sources, Info.plist files and Xcode build settings
and lists what those SDKs deprecate, ignore or refuse, each with what to write instead and a link
to Apple's documentation. It is for app developers who want the list before Xcode shows it, or
for the changes Xcode never reports: a UIKit app without a scene manifest does not launch when
built with the iOS 27 SDK, and the compiler says nothing about it.

## Highlights

- **Finds what stops an app from launching** — a UIKit app delegate without a scene manifest, or
  with a manifest that names no scene configuration, is reported as an error, following Apple's
  TN3187.
- **Finds what the compiler does not warn about** — app delegate methods that UIKit stops calling
  once the app uses scenes, `UIDesignRequiresCompatibility`, which iOS 27 ignores, and SwiftUI API
  that is deprecated only for a future release.
- **Every rule is checked against the SDK** — each of the 42 rules names the declaration in the
  iOS 27.1 SDK headers or Swift interfaces it is based on (`migration-scan --explain <rule>`).
- **Reads code, not text** — comments and strings never match, code inside string
  interpolations does, and calls and declarations match on their argument labels.
- **Output for every place you look** — plain text, Xcode issues, GitHub pull request annotations,
  SARIF for code scanning, and JSON. Reports never copy source code.
- **Guides with code that builds** — scene life cycle and Liquid Glass guides whose snippets come
  from the MigrationLab example app that CI builds and tests.

## Quick start

**1. Get the scanner**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Scan your app**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Fix what it reports**

Each finding says where, why and what to write instead. Two of the 21 findings for the legacy app
in [the test fixtures](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp):

```text
LegacyApp/LegacyApp/AppDelegate.swift:3:1: error: The app does not adopt the scene life cycle [scene-manifest-missing]
    This UIKit app has no UIApplicationSceneManifest. Built with the iOS 27 SDK, an app without the scene life cycle does not launch.
    Fix: Add a UIApplicationSceneManifest with a window scene configuration to Info.plist, add a UIWindowSceneDelegate and create the window in scene(_:willConnectTo:options:).
    See: https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle
…
LegacyApp/LegacyApp/AppDelegate.swift:11:43: warning: UIScreen.main [uiscreen-main]
    With scenes and external displays an app can be on more than one screen, so there is no single main screen; deprecated in iOS 26.0.
    Fix: Use view.window?.windowScene?.screen, or a trait such as traitCollection.displayScale for the scale.
    See: https://developer.apple.com/documentation/uikit/uiscreen/main
…
3 errors, 14 warnings, 4 info in 4 files.
```

Start with the errors. The [scene life cycle guide](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle)
walks through the most common one step by step.

## Installation

### Command line

Build it from a clone as in the quick start; the command is `.build/release/migration-scan`. To
run it without a clone, add the package to another package's dependencies and call
`swift run migration-scan`.

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS26-Migration-Guide.git", from: "2.0.0")
],
targets: [
    .target(name: "YourTool", dependencies: [
        .product(name: "MigrationScanner", package: "iOS26-Migration-Guide")
    ])
]
```

## Usage

### Choose what to report

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

The exit status is 1 when a finding reaches `--fail-on` (`error` by default; `warning`, `info`
or `never`), 2 for a wrong command line, and 0 otherwise.

### Show findings in Xcode

Add a Run Script build phase; Xcode lists each finding in the issue navigator:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Turn off `ENABLE_USER_SCRIPT_SANDBOXING` for that target, or the script cannot read the sources.

### Annotate pull requests

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` writes a report for GitHub code scanning instead; see the
[CI guide](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Keep a finding on purpose

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

A comment after code applies to its line, a comment on its own line to the next line, and
`// migration-scan:ignore-file <rules>` to the whole file. A comment that names an unknown rule is
reported instead of silently suppressing nothing.

### Scan from Swift

```swift
func scanProject(at folder: URL) -> String {
    let report = ProjectScanner().scan(paths: [folder])
    return ReportFormatter.format(report, as: .text)
}
```

```swift
func blockingFindings(in folder: URL) -> [Finding] {
    var configuration = ScanConfiguration(minimumSeverity: .warning)
    configuration.excludedDirectoryNames.insert("Generated")
    let report = ProjectScanner(configuration: configuration).scan(paths: [folder])
    return report.findings.filter { $0.severity == .error }
}
```

`scan(source:)` checks a single source text, which is how the example app rescans as you type:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Adopt the scene life cycle

The core of the move, from the example app's scene delegate: the window belongs to the window
scene, and the URL that launched the app arrives in the connection options.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Demo

[MigrationLab](Examples/MigrationLab) is a scene-based UIKit app with SwiftUI screens: a source
editor with live findings, the rule catalog, Liquid Glass on a custom control, and what the
window scene reports about itself. Open `Examples/MigrationLab/MigrationLab.xcodeproj` and run it
on an iOS 26 simulator. `migrationlab://rule/<rule-id>` opens a rule.

| Scanner | Rules | Liquid Glass | Scene |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="The scanner screen with a legacy app delegate and its findings" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="The searchable list of 42 rules" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Glass buttons in a glass effect container over a blue gradient" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="The window scene's role, windows, orientation and display scale" width="200"></picture> |

The screenshots come from the running app; `scripts/capture-example-screens.sh` takes them again.

## Documentation

Reference documentation and articles:

- [MigrationScanner on GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — the API reference
- [Getting started](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Rule reference](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — all 42 rules with their fixes

## Guides

- [Adopting the scene life cycle](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifest, scene delegate, moved methods and replacements for `UIScreen.main`
- [Adopting Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — stop opting out, remove custom backgrounds, renamed APIs, glass on custom controls
- [Running in Xcode and CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — build phase, pull request annotations, code scanning, JSON

## Requirements

| Platform | Minimum version |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Toolchain | Swift 6.2 (Xcode 26) |

## Architecture

- `Lexer` turns a Swift file into tokens and comments; string contents and comments never become
  tokens, interpolated code does.
- `BracketIndex` and `TokenIndex` index identifiers, bracket pairs, argument labels and closure
  parameters in one pass, so every matcher is linear in the size of the file.
- `RuleCatalog` holds the rules; each has a matcher (token sequence, member access, call or
  declaration with argument labels, or a project check), a severity and its SDK evidence.
- `ProjectFacts` collects app entry points, Info.plist values and build settings for the project
  rules. `PropertyListGuard` refuses property lists that are deeply nested, cyclic or malformed
  before the system parser reads them.
- `ProjectScanner` walks the files with size and count limits and never follows symbolic links;
  `ReportFormatter` writes the five formats and escapes control characters in paths.
- `MigrationScanCLI` parses and validates the command line; the `migration-scan` executable only
  forwards to it.

### Known limitations

- The scanner reads source text; it does not type-check. A rule such as `uiapplication-key-window`
  matches `UIApplication.shared.keyWindow`, not a `keyWindow` reached through another variable.
- Project rules assume one app per scanned folder: Info.plist files and build settings anywhere
  in the folder count for the app found there.
- It suggests replacements and never rewrites code.

## Roadmap

New rules follow new SDK releases; each one is added with the SDK declaration it is based on and
a sample it must report and one it must leave alone. Requests and reports go to
[issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Contributing

Contributions are welcome. Read the [contributing guide](CONTRIBUTING.md) and the [code of conduct](CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
