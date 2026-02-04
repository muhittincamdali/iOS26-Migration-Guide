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

<p align="center">
  <a href="#-overview">Overview</a> •
  <a href="#-whats-new">What's New</a> •
  <a href="#-migration-steps">Migration</a> •
  <a href="#-liquid-glass">Liquid Glass</a> •
  <a href="#-resources">Resources</a>
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [What's New in iOS 26](#-whats-new-in-ios-26)
- [Migration Checklist](#-migration-checklist)
- [Migration Steps](#-migration-steps)
- [Liquid Glass Migration](#-liquid-glass-migration)
- [Foundation Models](#-foundation-models)
- [Breaking Changes](#-breaking-changes)
- [Deprecated APIs](#-deprecated-apis)
- [Best Practices](#-best-practices)
- [Resources](#-resources)
- [Contributing](#-contributing)
- [License](#-license)
- [Star History](#-star-history)

---

## 📖 Overview

This guide helps developers migrate their iOS apps to iOS 26 with minimal friction. Follow the step-by-step instructions to update your codebase and adopt new features like Liquid Glass and Foundation Models.

---

## ✨ What's New in iOS 26

| Feature | Description | Impact |
|---------|-------------|--------|
| 🧊 **Liquid Glass** | Revolutionary new UI paradigm | High |
| 🤖 **Foundation Models** | On-device LLM capabilities | High |
| 📱 **App Intents 2.0** | Enhanced Shortcuts integration | Medium |
| 🔊 **Audio 2.0** | Spatial audio improvements | Medium |
| 📸 **Vision 2.0** | Enhanced image analysis | Medium |
| 🎨 **New SwiftUI Views** | Enhanced container views | High |
| ⚡ **Performance** | 40% faster rendering | High |
| 🔒 **Privacy** | Enhanced permission system | Medium |
| 📱 **Widgets** | Interactive widget actions | Medium |

---

## ✅ Migration Checklist

```
Pre-Migration
├── [ ] Backup current project
├── [ ] Review release notes
└── [ ] Check third-party dependencies

Setup
├── [ ] Update to Xcode 18+
├── [ ] Set deployment target to iOS 26
└── [ ] Enable Swift 6 mode

Code Updates
├── [ ] Adopt Liquid Glass design
├── [ ] Update deprecated APIs
├── [ ] Migrate to async/await
└── [ ] Update Foundation Models usage

Testing
├── [ ] Test on iOS 26 simulator
├── [ ] Test on physical devices
└── [ ] Submit to TestFlight
```

---

## 🚀 Migration Steps

### Step 1: Update Xcode

```bash
# Ensure Xcode 18+ is installed
xcode-select --install

# Verify version
xcodebuild -version
```

### Step 2: Update Deployment Target

```swift
// Package.swift
platforms: [
    .iOS(.v26),
    .macOS(.v15)
]
```

```ruby
# Podfile
platform :ios, '26.0'
```

### Step 3: Run Migration Tool

```bash
# Automatic migration
swift package migrate --target iOS26

# Manual migration check
swift build --target iOS26 2>&1 | grep -i deprecated
```

### Step 4: Update Info.plist

```xml
<key>MinimumOSVersion</key>
<string>26.0</string>
```

---

## 🧊 Liquid Glass Migration

The biggest visual change in iOS 26 is Liquid Glass - a new design language that replaces traditional blur effects.

### Basic Migration

```swift
// ❌ Before (iOS 25)
.background(.ultraThinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)

// ✅ After (iOS 26)
.glassBackground()
.glassBackground(style: .regular)
.glassBackground(style: .prominent)
```

### Advanced Options

```swift
// Customized Liquid Glass
.glassBackground(
    style: .frosted,
    opacity: 0.3,
    cornerRadius: 16
)

// With tint color
.glassBackground(tint: .blue.opacity(0.2))

// Interactive glass
.glassBackground(
    style: .adaptive,
    interaction: .reactive
)
```

### Migration Table

| iOS 25 Material | iOS 26 Liquid Glass |
|-----------------|---------------------|
| `.ultraThinMaterial` | `.glassBackground(style: .subtle)` |
| `.thinMaterial` | `.glassBackground(style: .light)` |
| `.regularMaterial` | `.glassBackground()` |
| `.thickMaterial` | `.glassBackground(style: .prominent)` |
| `.ultraThickMaterial` | `.glassBackground(style: .opaque)` |

---

## 🤖 Foundation Models

iOS 26 introduces on-device large language models through the Foundation Models framework.

### Basic Usage

```swift
import FoundationModels

// Initialize model
let model = try await LanguageModel.default

// Generate text
let response = try await model.generate(
    prompt: "Summarize this text: \(text)",
    maxTokens: 100
)

print(response.text)
```

### Advanced Features

```swift
// Streaming response
for try await chunk in model.stream(prompt: prompt) {
    print(chunk.text, terminator: "")
}

// With system prompt
let response = try await model.generate(
    prompt: userPrompt,
    systemPrompt: "You are a helpful assistant.",
    temperature: 0.7
)

// Structured output
let result: Recipe = try await model.generate(
    prompt: "Create a recipe for pasta",
    outputType: Recipe.self
)
```

---

## ⚠️ Breaking Changes

| API | Change | Migration Path |
|-----|--------|----------------|
| `UITableView` | Deprecated delegate methods | Use `UICollectionView` with compositional layout |
| `URLSession` | New async API required | Update to async/await |
| `UIBlurEffect` | Removed in iOS 26 | Use `LiquidGlass` views |
| `NavigationView` | Compilation error | Use `NavigationStack` |

### Code Examples

```swift
// ❌ UITableView (deprecated)
func tableView(_ tableView: UITableView, 
               cellForRowAt indexPath: IndexPath) -> UITableViewCell

// ✅ UICollectionView (recommended)
func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
```

---

## 🗑️ Deprecated APIs

### Fully Deprecated (Will Not Compile)

| Deprecated | Replacement | Deadline |
|------------|-------------|----------|
| `UIWebView` | `WKWebView` | iOS 26 |
| `UIAlertView` | `UIAlertController` | iOS 26 |
| `AddressBook` | `Contacts` framework | iOS 26 |

### Soft Deprecated (Warnings)

| Deprecated | Replacement | Deadline |
|------------|-------------|----------|
| `AsyncImage` | `CachedAsyncImage` | iOS 27 |
| `@State` arrays | `@Observable` | iOS 27 |
| `withAnimation` | `withSpringAnimation` | iOS 28 |

---

## 💡 Best Practices

### 1. Test Early and Often

```bash
# Run tests on iOS 26 simulator
xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,OS=26.0,name=iPhone 16'
```

### 2. Adopt Swift 6 Strictly

```swift
// Package.swift
swiftLanguageVersions: [.v6]

// Enable strict concurrency
swiftSettings: [
    .enableExperimentalFeature("StrictConcurrency")
]
```

### 3. Update Dependencies Regularly

```bash
# Check for outdated packages
swift package update --dry-run

# Update all packages
swift package update
```

### 4. Use Feature Flags

```swift
if #available(iOS 26, *) {
    // Use Liquid Glass
    view.glassBackground()
} else {
    // Fallback to material
    view.background(.regularMaterial)
}
```

---

## 📚 Resources

| Resource | Description | Link |
|----------|-------------|------|
| 📖 Apple Documentation | Official iOS 26 docs | [developer.apple.com/documentation](https://developer.apple.com/documentation) |
| 🎬 WWDC Videos | Session videos and labs | [developer.apple.com/wwdc](https://developer.apple.com/wwdc) |
| 💬 Swift Forums | Community discussions | [forums.swift.org](https://forums.swift.org) |
| 📝 Release Notes | iOS 26 release notes | [developer.apple.com/documentation/ios-ipados-release-notes](https://developer.apple.com/documentation/ios-ipados-release-notes) |
| 🛠️ Migration Tool | Official migration assistant | [developer.apple.com/xcode](https://developer.apple.com/xcode) |

---

## 🤝 Contributing

Found an issue or want to add more migration tips? Contributions are welcome!

1. Fork the repository
2. Create your branch (`git checkout -b feature/amazing-tip`)
3. Commit changes (`git commit -m 'Add amazing migration tip'`)
4. Push to branch (`git push origin feature/amazing-tip`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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

<div align="center">

**Made with ❤️ by [Muhittin Camdali](https://github.com/muhittincamdali)**

[⬆ Back to top](#ios-26-migration-guide)

</div>
