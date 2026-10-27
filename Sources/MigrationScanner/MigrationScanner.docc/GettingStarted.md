# Getting started

Scan an app in three steps and read what the scanner reports.

## Overview

You need a Mac with Xcode 26 or later. The scanner has no dependencies and does not change your
files.

### Step 1: Get the scanner

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

The command is now at `.build/release/migration-scan`.

### Step 2: Scan your app

Pass the folder that holds your Xcode project, or any folder or file inside it:

```sh
.build/release/migration-scan ~/Developer/MyApp
```

The scanner searches the folder for `.swift` files, `Info.plist` and `*-Info.plist` files,
`project.pbxproj`, `.xcconfig` files and XcodeGen `project.yml` specs. It skips `.build`,
`DerivedData`, `Pods`, `Carthage`, `node_modules`, hidden folders and symbolic links.

### Step 3: Read and fix the findings

Each finding looks like this:

```text
MyApp/AppDelegate.swift:11:43: warning: UIScreen.main [uiscreen-main]
    With scenes and external displays an app can be on more than one screen, so there is no single main screen; deprecated in iOS 26.0.
    Fix: Use view.window?.windowScene?.screen, or a trait such as traitCollection.displayScale for the scale.
    See: https://developer.apple.com/documentation/uikit/uiscreen/main
```

Start with the errors: they are things that stop compiling or launching. Warnings are deprecated
API that still works; info findings are soft deprecations and design review points. To read the
whole story behind a rule:

```sh
.build/release/migration-scan --explain scene-manifest-missing
```

``RuleCatalog`` lists every rule; <doc:RuleReference> has the same list on one page.

## Choose what to report

```sh
# Only errors and warnings
migration-scan --min-severity warning MyApp

# Skip rules, or run only some
migration-scan --disable navigation-view,foreground-color MyApp
migration-scan --only scene-manifest-missing,uiscreen-main MyApp

# Skip generated code
migration-scan --exclude Generated MyApp
```

The exit status is 0 when no finding reaches `--fail-on` (`error` by default; also `warning`,
`info` and `never`), 1 when one does, and 2 when the command line is wrong or a path does not
exist.

## Keep a finding on purpose

Some findings are deliberate, for example `UIScreen.main` in a widget extension that has no
window. Mark them in the source, with a reason after `--`:

```swift
let scale = UIScreen.main.scale // migration-scan:ignore uiscreen-main -- the widget has no window

// migration-scan:ignore uiapplication-windows
let window = UIApplication.shared.windows.first
```

A comment after code applies to its own line; a comment on a line of its own applies to the next
line. `// migration-scan:ignore-file <rules>` applies to the whole file, and `all` names every
rule. A comment that names a rule that does not exist is reported as a notice and suppresses
nothing, so a typo cannot hide a finding.

## Use the library

The same scanner is a Swift package library:

```swift
import MigrationScanner

let scanner = ProjectScanner(configuration: ScanConfiguration(minimumSeverity: .warning))
let report = scanner.scan(paths: [URL(filePath: "MyApp")])
if report.hasFindings(atLeast: .error) {
    print(ReportFormatter.format(report, as: .xcode))
}
```

``ProjectScanner/scan(source:file:)`` checks a single source text with the source rules, which is
what the example app's scanner screen does as you type.
