# UIKit Changes in iOS 26

> Back to [main guide](../README.md)

This document covers UIKit deprecations, removals, and new APIs in iOS 26.

---

## Table of Contents

- [Removed APIs](#removed-apis)
- [Deprecated APIs](#deprecated-apis)
- [New APIs](#new-apis)
- [Liquid Glass in UIKit](#liquid-glass-in-uikit)
- [Trait System Updates](#trait-system-updates)
- [Collection View Updates](#collection-view-updates)
- [View Controller Lifecycle](#view-controller-lifecycle)

---

## Removed APIs

These APIs no longer exist in the iOS 26 SDK. Code using them will fail to compile.

### UITableView

```swift
// ❌ Removed
let tableView = UITableView(frame: .zero, style: .insetGrouped)
tableView.dataSource = self
tableView.delegate = self

// ✅ Replacement — UICollectionView with list layout
var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
configuration.headerMode = .supplementary
let layout = UICollectionViewCompositionalLayout.list(using: configuration)
let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
```

### UINavigationBar.appearance()

```swift
// ❌ Removed — Global appearance proxy
UINavigationBar.appearance().barTintColor = .systemBlue
UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]

// ✅ Replacement — Per-instance configuration
let appearance = UINavigationBarAppearance()
appearance.configureWithLiquidGlass()
appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
navigationBar.standardAppearance = appearance
```

### UIScreen.main

```swift
// ❌ Removed
let bounds = UIScreen.main.bounds
let scale = UIScreen.main.scale

// ✅ Replacement — Window scene based
let scene = view.window?.windowScene
let bounds = scene?.screen.bounds ?? .zero
let scale = scene?.screen.scale ?? 1.0
```

### Completion-Handler APIs

Many older APIs with completion handlers are removed. Use async equivalents:

```swift
// ❌ Removed
PHPhotoLibrary.requestAuthorization { status in }

// ✅ Replacement
let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
```

---

## Deprecated APIs

These compile but produce warnings. Plan to migrate before iOS 27.

| API | Replacement | Target Removal |
|-----|-------------|---------------|
| `CADisplayLink` | `UIUpdateLink` | iOS 28 |
| `UIView.animate(withDuration:)` | `UIView.animate(springDuration:)` | iOS 28 |
| `UIActivityIndicatorView` | `UIProgressView` with `.circular` | iOS 28 |
| `UIPageControl` (old init) | `UIPageControl(currentPage:pageCount:)` | iOS 28 |
| `layoutSubviews()` override | `updateLayout(with:)` | iOS 28 |

### CADisplayLink → UIUpdateLink

```swift
// ❌ Deprecated
let displayLink = CADisplayLink(target: self, selector: #selector(step))
displayLink.add(to: .main, forMode: .common)

@objc func step(link: CADisplayLink) {
    let dt = link.targetTimestamp - link.timestamp
    updateAnimation(deltaTime: dt)
}

// ✅ New
let updateLink = UIUpdateLink(view: animatedView) { link, info in
    updateAnimation(deltaTime: info.modelTime)
}
updateLink.isEnabled = true
updateLink.preferredFrameRateRange = .init(minimum: 30, maximum: 120, preferred: 60)
```

---

## New APIs

### UIUpdateLink

High-precision update loop tied to a specific view's display.

```swift
class ParticleView: UIView {
    private var updateLink: UIUpdateLink?
    private var particles: [Particle] = []

    func startAnimation() {
        updateLink = UIUpdateLink(view: self) { [weak self] link, info in
            self?.updateParticles(deltaTime: info.modelTime)
            self?.setNeedsDisplay()
        }
        updateLink?.isEnabled = true
    }

    func stopAnimation() {
        updateLink?.isEnabled = false
    }
}
```

### UIGlassButton

```swift
let button = UIGlassButton(configuration: .filled())
button.configuration?.title = "Subscribe"
button.configuration?.image = UIImage(systemName: "star.fill")
button.glassStyle = .prominent
button.addAction(UIAction { _ in subscribe() }, for: .touchUpInside)
```

### UIBackgroundConfiguration.glassConfiguration

```swift
var config = UIBackgroundConfiguration.glassConfiguration()
config.glassStyle = .regular
config.cornerRadius = 12
cell.backgroundConfiguration = config
```

### UIView.animate(springDuration:)

```swift
// ✅ iOS 26 — Spring animation as default
UIView.animate(springDuration: 0.5, bounce: 0.3) {
    view.transform = .identity
}
```

---

## Liquid Glass in UIKit

### Navigation Bar

```swift
let appearance = UINavigationBarAppearance()
appearance.configureWithLiquidGlass()
navigationController?.navigationBar.standardAppearance = appearance
navigationController?.navigationBar.scrollEdgeAppearance = appearance
navigationController?.navigationBar.compactAppearance = appearance
```

### Tab Bar

```swift
let appearance = UITabBarAppearance()
appearance.configureWithLiquidGlass()
tabBarController?.tabBar.standardAppearance = appearance
tabBarController?.tabBar.scrollEdgeAppearance = appearance
```

### Toolbar

```swift
let appearance = UIToolbarAppearance()
appearance.configureWithLiquidGlass()
navigationController?.toolbar.standardAppearance = appearance
navigationController?.toolbar.scrollEdgeAppearance = appearance
```

---

## Trait System Updates

### New Traits

```swift
// Register for glass style changes
registerForTraitChanges([UITraitPreferredGlassStyle.self]) { (self: Self, _) in
    self.updateGlassAppearance()
}

// Read thermal state trait
let thermal = traitCollection.thermalState
```

### Custom Traits

```swift
// ✅ iOS 26 — Define custom traits
struct CompactLayoutTrait: UITraitDefinition {
    static let defaultValue = false
    static let affectsColorAppearance = false
}

extension UITraitCollection {
    var usesCompactLayout: Bool {
        self[CompactLayoutTrait.self]
    }
}

// Override in a view controller
override func updateTraitsIfNeeded() {
    let isCompact = view.bounds.width < 400
    traitOverrides[CompactLayoutTrait.self] = isCompact
}
```

---

## Collection View Updates

### Self-Sizing Improvements

```swift
// ✅ iOS 26 — Automatic estimated sizes are more accurate
var config = UICollectionLayoutListConfiguration(appearance: .plain)
config.estimatedHeight = .automatic  // New: system estimates better
let layout = UICollectionViewCompositionalLayout.list(using: config)
```

### Section Snapshot Animations

```swift
// ✅ iOS 26 — Custom animation for section snapshots
var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
snapshot.append(items)
dataSource.apply(snapshot, to: section, animatingDifferences: true) {
    // Completion handler
}
```

---

## View Controller Lifecycle

### `updateLayout(with:)` — New Layout Hook

```swift
class MyViewController: UIViewController {
    // ❌ Deprecated
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCustomLayout()
    }

    // ✅ iOS 26 — New hook with trait context
    override func updateLayout(with context: UILayoutContext) {
        super.updateLayout(with: context)
        // context provides size, traits, and safe area
        if context.availableSize.width > 600 {
            applyWideLayout()
        } else {
            applyCompactLayout()
        }
    }
}
```

### Presentation Lifecycle

```swift
// ✅ iOS 26 — New presentation callbacks
class MyViewController: UIViewController {
    override func willPresent(animated: Bool) {
        // Called before presentation animation
    }

    override func didPresent(animated: Bool) {
        // Called after presentation completes
    }

    override func willDismiss(animated: Bool) {
        // Called before dismissal animation
    }

    override func didDismiss(animated: Bool) {
        // Called after dismissal completes
    }
}
```

---

> 📖 Back to [main guide](../README.md) | Next: [Swift 6.2](swift-6.2.md)
