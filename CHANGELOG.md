# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-27

The repository becomes a tool with guides instead of a collection of guide pages.

### Added

- `MigrationScanner` library and `migration-scan` command: 42 rules for the scene life cycle,
  UIKit, Liquid Glass, SwiftUI and the Swift 6 language mode, each based on a declaration in the
  iOS 27.1 SDK headers or Swift interfaces, TN3187 or Apple's property list reference.
- Project rules: a UIKit app without a scene manifest (it does not launch with the iOS 27 SDK), a
  manifest without a scene configuration, and `UIDesignRequiresCompatibility` (ignored when
  building for iOS 27), read from Info.plist files, `project.pbxproj`, `.xcconfig` files and
  XcodeGen specs.
- Output as text, Xcode issues, GitHub annotations, JSON and SARIF 2.1.0; exit status from
  `--fail-on`; `--min-severity`, `--disable`, `--only`, `--exclude`, `--list-rules`, `--explain`.
- `migration-scan:ignore` and `migration-scan:ignore-file` comments, validated against the rule
  catalog.
- MigrationLab example app: a scene-based UIKit app with a live scanner, the rule catalog,
  Liquid Glass on a custom control and the scene's own geometry, with UI tests.
- DocC documentation: getting started, the rule reference, and guides for the scene life cycle,
  Liquid Glass and running in Xcode and CI.

### Removed

- The Markdown guide pages, examples and scripts of 1.0.0. They described APIs that the SDKs do
  not have (for example `UIGlassButton`) and removals that did not happen (for example
  `UITableView`), and the scripts reported or rewrote code on that basis.

### Security

- Scanning is bounded: file size and count limits, no symbolic links followed, linear lexing and
  matching, and property lists checked for depth, cycles and out-of-range offsets before parsing.
- The binary property list check is linear in the size of the file: objects that share an offset
  are expanded once, and containers that overlap, holding more references than the file has
  bytes, are refused.
- The XML depth check reads markup as the system parser does. Markup inside a tag or a DOCTYPE
  literal, a DOCTYPE internal subset, encodings other than UTF-8, US-ASCII and ISO-8859-1
  (in UTF-7, `+ADw-` is a `<`) and any 0x00 byte (UTF-16 and UTF-32 text, with or without a
  byte-order mark) are refused, so nesting can no longer be hidden from the check.
- Reports never contain source text, and control and bidirectional characters in paths are
  escaped in every format.

## [1.0.0] - 2026-02-03

### Added

- Markdown migration guide for iOS 26 with Liquid Glass, Swift 6 and framework pages.

[Unreleased]: https://github.com/muhittincamdali/iOS26-Migration-Guide/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/iOS26-Migration-Guide/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/iOS26-Migration-Guide/releases/tag/v1.0.0
