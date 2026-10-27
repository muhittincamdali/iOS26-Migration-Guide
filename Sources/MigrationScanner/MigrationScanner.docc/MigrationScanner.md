# ``MigrationScanner``

Find what the iOS 26 and iOS 27 SDKs deprecate, ignore or refuse in an app, and what to write instead.

## Overview

MigrationScanner reads a project's Swift sources, Info.plist files and Xcode build settings and
reports the places that need work before or after moving to the iOS 26 and iOS 27 SDKs. Each
finding names a rule, explains why it matters, says what to write instead and links to Apple's
documentation. Every rule was checked against the iOS 27.1 SDK headers and Swift interfaces, and
names the declaration it is based on.

The rules cover what the compiler does not report:

- A UIKit app without a scene manifest **does not launch** when it is built with the iOS 27 SDK
  (TN3187). The scanner finds the app delegate entry point and looks for the manifest in Info.plist
  files and build settings.
- App delegate methods such as `applicationDidBecomeActive(_:)` and
  `application(_:open:options:)` raise no warning when you implement them, but UIKit no longer
  calls them once the app uses scenes.
- `UIDesignRequiresCompatibility` keeps the pre-Liquid Glass design only until the app is built for
  iOS 27; the system ignores it from then on.
- Soft-deprecated SwiftUI API (marked `deprecated: 100000.0`) gets no compiler warning yet.

Run it from the command line, in Xcode or in CI with the `migration-scan` command, or call
``ProjectScanner`` from Swift:

```swift
import MigrationScanner

let report = ProjectScanner().scan(paths: [URL(filePath: "MyApp")])
print(ReportFormatter.format(report, as: .text))
```

The scanner only reads files. Reports contain rule identifiers, paths and positions, never text
copied from the scanned files.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:RuleReference>

### Guides

- <doc:AdoptingTheSceneLifeCycle>
- <doc:AdoptingLiquidGlass>
- <doc:RunningInXcodeAndCI>

### Scanning

- ``ProjectScanner``
- ``ScanConfiguration``
- ``ScanReport``
- ``Finding``
- ``Notice``
- ``SourceLocation``

### Rules

- ``RuleCatalog``
- ``Rule``
- ``RuleCategory``
- ``Severity``

### Reports

- ``ReportFormatter``
- ``ReportFormat``
- ``OutputSanitizer``
