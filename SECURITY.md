# Security policy

## Supported versions

Security fixes go into the latest release of `migration-scan` and the `MigrationScanner` library.

## Reporting a vulnerability

Report a vulnerability privately through
[GitHub's private vulnerability reporting](https://github.com/muhittincamdali/iOS26-Migration-Guide/security/advisories/new),
not in a public issue. Include the scanner version (`migration-scan --version`), the command line
and, if you can, a file that triggers the problem. You get an answer within a week.

## What the scanner is designed to withstand

The scanner reads files it did not write: sources, property lists and project files from any
repository, including pull requests from strangers. These are the properties it keeps, and a
report that breaks one of them is a vulnerability:

- **It only reads.** No rule changes a file, runs code from the project, or makes a network
  request.
- **Reports contain no source text.** A finding has a rule, a path and a position; explanations
  come from the rule catalog. A secret in a scanned file does not reach any report format.
- **Paths cannot forge output.** Control characters, line and paragraph separators,
  bidirectional formatting characters and the byte order mark in a path are written as
  `\u{…}`; GitHub workflow commands are escaped as `@actions/core` does.
- **Bounded work.** Files are read with a size cap (4 MiB by default), the walk stops at a file
  count, symbolic links inside a folder are not followed, and lexing and matching are linear in
  the size of a file, also for nested or unclosed brackets.
- **No crash on hostile property lists.** Property lists nested deeper than 64 levels, binary
  property lists with cycles or offsets outside the file, XML with entity declarations and the
  OpenStep format are refused before `PropertyListSerialization` reads them. XML depth is counted
  outside comments, CDATA sections and processing instructions, and a closing tag without a
  matching opening tag refuses the file.
- **No trap on hostile numbers.** Command-line numbers that do not fit an `Int` are rejected, and
  64-bit fields in binary property lists are compared with the file size before conversion.

Out of scope: findings that are wrong or missing (open an issue), and the security of the apps
that are scanned.
