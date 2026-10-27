# Contributing

Thank you for helping. Bug reports, wrong or missing findings, new rules and documentation fixes
are all welcome.

## Report a wrong or missing finding

Open an issue with the smallest Swift code, Info.plist or build setting that shows it, the
finding you got or expected, and `migration-scan --version`. Do not paste private code: reduce it
to the API call that matters.

## Add or change a rule

Every rule must be traceable to Apple's SDK or documentation:

1. Find the declaration in the current SDK headers or Swift interfaces (for example
   `UIApplication.h` or `SwiftUI.swiftinterface`) and note its deprecation version and message.
   A rule based on memory, a blog post or a beta that changed later is not accepted.
2. Add the rule to the right file in `Sources/MigrationScanner/Rules/`, with the declaration in
   `evidence` and Apple's page for the replacement in `documentation`.
3. Add a sample it must report and one it must ignore to `Tests/MigrationScannerTests/RuleSampleTests.swift`.
   The test suite fails until every rule has both.
4. Regenerate the rule reference:

   ```sh
   swift run migration-scan --list-rules --format json | node scripts/rule-catalog.mjs
   ```

## Development

```sh
swift build
swift test
```

Before opening a pull request, also check that the example app builds and passes its UI tests,
and that it still has no findings of its own:

```sh
swift run migration-scan Examples --fail-on info
xcodebuild test -project Examples/MigrationLab/MigrationLab.xcodeproj -scheme MigrationLab \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

After changing `Examples/MigrationLab/project.yml`, run `xcodegen` in that folder. After changing
the example app's screens, run `scripts/capture-example-screens.sh` to update the screenshots.

## Style

- Swift 6 language mode, no dependencies, Foundation only in the library.
- Work on scanned input must stay linear and bounded; add a test with pathological input for any
  new parsing code.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).

By contributing you agree to follow the [code of conduct](CODE_OF_CONDUCT.md) and that your
contribution is released under the [MIT license](LICENSE).
