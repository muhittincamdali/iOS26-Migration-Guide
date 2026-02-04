<p align="center">
  <img src="Assets/logo.png" alt="iOS 26 Migration Guide" width="200"/>
</p>

<h1 align="center">iOS 26 Migration Guide</h1>

<p align="center">
  <strong>📖 The definitive iOS 25 → iOS 26 migration guide with Liquid Glass</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-26-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 26"/>
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift"/>
  <img src="https://img.shields.io/badge/Xcode-16-1575F9?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/github/stars/muhittincamdali/iOS26-Migration-Guide?style=for-the-badge&logo=github" alt="Stars"/>
</p>

---

## What's New in iOS 26

| Feature | Description |
|---------|-------------|
| 🧊 **Liquid Glass** | New UI paradigm |
| 🤖 **Foundation Models** | On-device LLM |
| 📱 **App Intents 2.0** | Enhanced Shortcuts |
| 🔊 **Audio 2.0** | Spatial audio improvements |
| 📸 **Vision 2.0** | Enhanced image analysis |

## Migration Checklist

- [ ] Update to Xcode 18
- [ ] Set deployment target to iOS 26
- [ ] Adopt Liquid Glass design
- [ ] Update deprecated APIs
- [ ] Test on new simulators
- [ ] Submit to TestFlight

## Liquid Glass Migration

```swift
// Before (iOS 25)
.background(.ultraThinMaterial)

// After (iOS 26)
.glassBackground()

// With options
.glassBackground(
    style: .frosted,
    opacity: 0.3
)
```

## Foundation Models

```swift
import FoundationModels

let model = try await LanguageModel.default

let response = try await model.generate(
    prompt: "Summarize this text: \(text)",
    maxTokens: 100
)
```

## Deprecated APIs

| Deprecated | Replacement |
|------------|-------------|
| `UIBlurEffect` | `LiquidGlass` |
| `NavigationView` | `NavigationStack` |
| `AsyncImage` | `CachedAsyncImage` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/iOS26-Migration-Guide&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
 </picture>
</a>

---

## 📋 Table of Contents

- [Overview](#overview)
- [What's New in iOS 26](#whats-new-in-ios-26)
- [Migration Steps](#migration-steps)
- [Breaking Changes](#breaking-changes)
- [Deprecated APIs](#deprecated-apis)
- [Best Practices](#best-practices)
- [Resources](#resources)

## Overview

This guide helps developers migrate their iOS apps to iOS 26 with minimal friction. Follow the step-by-step instructions to update your codebase.

## What's New in iOS 26

| Feature | Description |
|---------|-------------|
| 🎨 **New SwiftUI Views** | Enhanced container views |
| ⚡ **Performance** | 40% faster rendering |
| 🔒 **Privacy** | Enhanced permission system |
| 📱 **Widgets** | Interactive widget actions |

## Migration Steps

### Step 1: Update Xcode

```bash
# Ensure Xcode 16+ is installed
xcode-select --install
```

### Step 2: Update Deployment Target

```swift
// Package.swift
platforms: [
    .iOS(.v26)
]
```

### Step 3: Run Migration Tool

```bash
swift package migrate --target iOS26
```

## Breaking Changes

| API | Change | Migration |
|-----|--------|-----------|
| `UITableView` | Deprecated delegate methods | Use `UICollectionView` |
| `URLSession` | New async API | Update to async/await |

## Deprecated APIs

- `UIWebView` - Use `WKWebView`
- `UIAlertView` - Use `UIAlertController`
- `addressBook` framework - Use `Contacts`

## Best Practices

1. **Test Early** - Use iOS 26 beta
2. **Adopt Swift 6** - Enable strict concurrency
3. **Update Dependencies** - Check SPM packages

## Resources

| Resource | Link |
|----------|------|
| Apple Documentation | [developer.apple.com](https://developer.apple.com) |
| WWDC Videos | [developer.apple.com/wwdc](https://developer.apple.com/wwdc) |
| Swift Forums | [forums.swift.org](https://forums.swift.org) |

## Contributing

Found an issue? Open a PR! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - see [LICENSE](LICENSE).

---

<div align="center">

**Made with ❤️ by [Muhittin Camdali](https://github.com/muhittincamdali)**

</div>
