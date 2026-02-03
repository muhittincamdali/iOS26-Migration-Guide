# Contributing to iOS 26 Migration Guide

First off, thanks for taking the time to contribute! 🎉

This guide is a community effort, and every contribution makes it better for everyone migrating to iOS 26.

## How Can I Contribute?

### Reporting Issues

- **Inaccurate information**: If you find something that doesn't match Apple's documentation or your real-world experience, please open an issue.
- **Missing topics**: If a migration scenario isn't covered, let us know.
- **Broken links**: Report any dead links you encounter.

### Submitting Pull Requests

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b docs/your-topic`
3. **Make** your changes
4. **Commit** with a clear message: `docs: add migration notes for PhotosUI`
5. **Push** to your fork and open a **Pull Request**

### Writing Guidelines

- **Language**: All content must be in English
- **Code examples**: Use Swift with proper syntax highlighting (` ```swift `)
- **Before/After**: When documenting changes, show the old way and the new way
- **Be specific**: Include minimum deployment targets and SDK versions
- **Link sources**: Reference Apple documentation, WWDC sessions, or release notes
- **No opinions**: Stick to facts and practical guidance

### Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
docs: add Core Location migration notes
fix: correct SwiftData code example
feat: add watchOS migration section
chore: update table of contents
```

### File Structure

- `README.md` — Main guide with overview of all topics
- `docs/*.md` — Deep-dive documents for specific topics
- Keep each doc focused on a single topic
- Add new docs to the Table of Contents in README.md

### Code Examples

- Must compile (or be clearly marked as pseudocode)
- Use iOS 26 SDK / Swift 6.2 syntax
- Include `import` statements when relevant
- Keep examples minimal but complete

### Style

- Use `##` for main sections, `###` for subsections
- Use tables for comparison data
- Use checkbox lists (`- [ ]`) for actionable items
- Add horizontal rules (`---`) between major sections

## Code of Conduct

Be respectful, constructive, and welcoming. We're all here to learn.

## Questions?

Open a [Discussion](../../discussions) if you're unsure about something. We're happy to help!
