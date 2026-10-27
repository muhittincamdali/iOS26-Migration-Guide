## What changes

<!-- What this pull request changes and why. Link the issue it closes. -->

## Checklist

- [ ] `swift test` passes
- [ ] New or changed rules name their SDK declaration in `evidence` and have samples in `RuleSampleTests.swift`
- [ ] The rule reference is regenerated (`scripts/rule-catalog.mjs`) when rules changed
- [ ] The example app builds and `swift run migration-scan Examples --fail-on info` finds nothing
- [ ] `CHANGELOG.md` has an entry under Unreleased
