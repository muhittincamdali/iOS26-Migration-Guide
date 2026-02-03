<div align="center">

# 📖 iOS 26 Migration Guide

**The definitive iOS 25 → iOS 26 migration guide with Liquid Glass**

[![iOS](https://img.shields.io/badge/iOS-26-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Stars](https://img.shields.io/github/stars/muhittincamdali/iOS26-Migration-Guide?style=for-the-badge)](https://github.com/muhittincamdali/iOS26-Migration-Guide/stargazers)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 📋 Contents

- [What's New in iOS 26](#-whats-new)
- [Liquid Glass](#-liquid-glass)
- [Breaking Changes](#-breaking-changes)
- [Migration Steps](#-migration-steps)
- [Code Examples](#-code-examples)

---

## ✨ What's New

### 🧊 Liquid Glass
The revolutionary new design language featuring dynamic translucent materials.

### 🤖 Foundation Models
On-device AI with Apple Intelligence integration.

### 📱 Enhanced SwiftUI
New navigation patterns and view modifiers.

---

## 🔄 Migration Steps

### 1. Update Deployment Target
```swift
// Package.swift
platforms: [.iOS(.v26)]
```

### 2. Adopt Liquid Glass
```swift
.liquidGlass() // New modifier
```

### 3. Update Deprecated APIs
See [Deprecation Guide](Documentation/Deprecations.md)

---

## 📚 Resources

- [Full Migration Checklist](Documentation/Checklist.md)
- [Code Examples](Examples/)
- [Troubleshooting](Documentation/Troubleshooting.md)

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
