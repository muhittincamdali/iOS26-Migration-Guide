# Running in Xcode and CI

Show findings in Xcode's issue navigator, as pull request annotations, or in GitHub code scanning.

## Overview

The `migration-scan` command picks its output with `--format` and reports failure through its
exit status, so the same command works in a build phase, a CI job or a pre-commit hook.

### Show findings in Xcode

Build the command once and add a Run Script build phase to the app target:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" \
  --format xcode --fail-on never "$SRCROOT"
```

With `--format xcode`, every finding is a `file:line:column: warning: ...` line, which Xcode lists
in the issue navigator and shows next to the code; info findings appear as notes. `--fail-on never`
keeps the build going; use `--fail-on error` to stop it when an error is found.

Run Script phases are sandboxed when `ENABLE_USER_SCRIPT_SANDBOXING` is `YES` (the default in new
projects), and a sandboxed script cannot read the sources. Turn the setting off for the target
that runs the scan, or run the scan from CI instead.

### Annotate pull requests on GitHub

`--format github` prints workflow commands; GitHub shows them on the changed lines of a pull
request and in the run summary:

```yaml
name: Migration scan

on: pull_request

permissions:
    contents: read

jobs:
    scan:
        runs-on: macos-26
        steps:
            - uses: actions/checkout@v7
            - uses: actions/checkout@v7
              with:
                  repository: muhittincamdali/iOS26-Migration-Guide
                  path: .migration-scan
            - name: Scan
              run: |
                  swift build -c release --package-path .migration-scan
                  .migration-scan/.build/release/migration-scan --format github .
```

The job fails when the scan finds an error; add `--fail-on warning` to fail on warnings too. Pin
the scanner checkout to a release tag with `ref:` so new rules do not change the result of an
unchanged pull request. The scanner skips hidden folders such as `.migration-scan`, so its own
sources are not scanned.

### Upload results to code scanning

SARIF output lists the whole rule catalog with each rule's explanation and documentation link,
so GitHub code scanning can show the findings with their fixes:

```yaml
- name: Scan
  run: |
      swift build -c release --package-path .migration-scan
      .migration-scan/.build/release/migration-scan --format sarif --fail-on never \
        . > migration.sarif
- uses: github/codeql-action/upload-sarif@v4
  with:
      sarif_file: migration.sarif
```

Uploading needs `security-events: write` permission for the job.

### Process the report in a script

`--format json` writes a document with sorted keys: a summary with the counts, then each finding
with its rule, severity, category, title, explanation, fix, documentation link, file, line and
column. The same scan gives the same bytes, so the output can be stored and compared.

```sh
migration-scan --format json --fail-on never MyApp | jq '.summary'
```

### Limits

Files larger than 4 MiB are skipped with a notice (`--max-file-size`), and the scan stops after
100,000 files (`--max-files`). Symbolic links inside a scanned folder are not followed. An
Info.plist that is not a property list, is nested more than 64 levels deep, or uses XML that the
scanner could read differently from the system parser (a DOCTYPE internal subset, markup inside a
tag, an encoding other than UTF-8, US-ASCII or ISO-8859-1, UTF-16 or UTF-32 text) is skipped with an
`invalid-property-list` notice, and the project rules do not use its values. Paths are
the only text in a report that does not come from the rule catalog; control characters and
bidirectional formatting characters in them are written as `\u{…}`, so a file name cannot add
lines to the output.
