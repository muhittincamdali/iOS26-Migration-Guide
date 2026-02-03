# iOS 26 Migration Checklist

> Back to [main guide](../README.md)

Print this checklist or copy it into your project management tool to track migration progress.

---

## 🔧 Environment Setup

- [ ] Install Xcode 27.0
- [ ] Update macOS to version 16
- [ ] Update CocoaPods / SPM dependencies
- [ ] Verify all third-party SDKs support iOS 26
- [ ] Set deployment target to iOS 17.0 minimum

## 🔴 Breaking Changes (Must Fix)

- [ ] Remove all `UITableView` usage → `UICollectionView` with list layout
- [ ] Remove `UINavigationBar.appearance()` → `UINavigationBarAppearance`
- [ ] Remove `UITabBar.appearance()` → `UITabBarAppearance`
- [ ] Remove `UIScreen.main` → window scene-based access
- [ ] Replace `ObservableObject` / `@Published` → `@Observable`
- [ ] Replace `@StateObject` → `@State` with `@Observable`
- [ ] Replace `@EnvironmentObject` → `@Environment`
- [ ] Remove `AnyView` from lazy containers
- [ ] Migrate completion handler APIs → async/await
- [ ] Remove `NSCoding` usage from `UIColor`
- [ ] Fix `UIApplication.shared` usage in extensions

## 🎨 Liquid Glass

- [ ] Test automatic Liquid Glass on navigation bars
- [ ] Test automatic Liquid Glass on tab bars
- [ ] Migrate custom `UIBlurEffect` views → `UILiquidGlassEffect`
- [ ] Update SwiftUI `.material` usage → `.liquidGlass`
- [ ] Test glass rendering on oldest supported device
- [ ] Verify Reduce Transparency accessibility fallback
- [ ] Profile glass performance with Instruments

## 🖼️ SwiftUI

- [ ] Replace `NavigationView` → `NavigationStack` / `NavigationSplitView`
- [ ] Replace `.navigationBarTitle` → `.navigationTitle`
- [ ] Update `.sheet` / `.fullScreenCover` → `.presentation` (optional)
- [ ] Adopt new scene lifecycle callbacks
- [ ] Test mesh gradients if using custom gradients
- [ ] Audit `GeometryReader` usage — consider `Layout` protocol

## 🏗️ UIKit

- [ ] Replace `CADisplayLink` → `UIUpdateLink`
- [ ] Update collection view estimated heights
- [ ] Adopt new view controller lifecycle hooks
- [ ] Test trait system changes

## ⚡ Swift 6.2

- [ ] Enable strict concurrency checking
- [ ] Fix all `Sendable` warnings/errors
- [ ] Audit global mutable state
- [ ] Adopt typed throws where beneficial
- [ ] Update Package.swift to swift-tools-version: 6.2

## 📦 Data & Networking

- [ ] Plan Core Data → SwiftData migration (if applicable)
- [ ] Test HTTP/3 default behavior
- [ ] Update `URLSession` delegates for `Sendable`
- [ ] Migrate background transfer code

## 🔒 Privacy

- [ ] Update `PrivacyInfo.xcprivacy`
- [ ] Audit tracking domains
- [ ] Test App Tracking Transparency v2
- [ ] Verify security-scoped file access

## 🤖 Intents & Widgets

- [ ] Migrate SiriKit intents → App Intents
- [ ] Add `AppShortcutsProvider`
- [ ] Update widgets for interactive controls
- [ ] Test Live Activity improvements

## 🧪 Testing

- [ ] Verify tests pass with parallel execution
- [ ] Fix tests with shared mutable state
- [ ] Begin adopting Swift Testing for new tests
- [ ] Add snapshot tests for key screens
- [ ] Run performance benchmarks

## 🚀 Release Prep

- [ ] Full regression test on iOS 26 simulator
- [ ] Test on physical device (iPhone XS or later)
- [ ] Accessibility audit
- [ ] Performance profiling with Instruments
- [ ] Submit to TestFlight
- [ ] Monitor crash reports during beta
- [ ] Phased App Store rollout

---

## Progress Tracker

| Phase | Items | Done | Remaining |
|-------|-------|------|-----------|
| Environment | 5 | _ | _ |
| Breaking Changes | 11 | _ | _ |
| Liquid Glass | 7 | _ | _ |
| SwiftUI | 6 | _ | _ |
| UIKit | 4 | _ | _ |
| Swift 6.2 | 5 | _ | _ |
| Data & Networking | 4 | _ | _ |
| Privacy | 4 | _ | _ |
| Intents & Widgets | 4 | _ | _ |
| Testing | 5 | _ | _ |
| Release | 7 | _ | _ |
| **Total** | **62** | _ | _ |

---

> 📖 Back to [main guide](../README.md)
