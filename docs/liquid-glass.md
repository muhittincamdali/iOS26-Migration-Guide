# Liquid Glass — Deep Dive

> Back to [main guide](../README.md)

Liquid Glass is Apple's new material system introduced in iOS 26. It replaces the traditional blur-based materials with a physically-modeled translucent glass effect that responds to depth, lighting, and content behind it.

---

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Automatic Adoption](#automatic-adoption)
- [UIKit Integration](#uikit-integration)
- [SwiftUI Integration](#swiftui-integration)
- [Glass Styles Reference](#glass-styles-reference)
- [Custom Glass Views](#custom-glass-views)
- [Navigation Bar Customization](#navigation-bar-customization)
- [Tab Bar Customization](#tab-bar-customization)
- [Interaction with Dark Mode](#interaction-with-dark-mode)
- [Performance Considerations](#performance-considerations)
- [Accessibility](#accessibility)
- [Migration from UIBlurEffect](#migration-from-uiblureffect)
- [Common Pitfalls](#common-pitfalls)

---

## Overview

Liquid Glass creates a translucent surface that:

- Refracts content behind it with physically-based optics
- Responds to ambient lighting conditions
- Adapts depth perception based on scroll position
- Maintains readability of foreground content automatically

## How It Works

The Liquid Glass renderer uses a multi-pass compositing pipeline:

```
┌──────────────────────────────────┐
│  1. Background Content Capture   │
│  2. Depth Map Generation         │
│  3. Refraction Calculation       │
│  4. Tint & Saturation Pass       │
│  5. Foreground Compositing       │
└──────────────────────────────────┘
```

The system captures the content behind the glass surface, generates a depth map, applies refraction based on the glass style, and composites the final result with adaptive tinting.

---

## Automatic Adoption

When you compile your existing app with the iOS 26 SDK, the following elements automatically receive Liquid Glass:

| Element | Behavior |
|---------|----------|
| `UINavigationBar` | Standard and scroll-edge appearances use glass |
| `UITabBar` | Background becomes glass material |
| `UIToolbar` | Translucent toolbars use glass |
| `UISearchBar` | Search field background becomes glass |
| `.sheet` presentations | Sheet chrome uses glass material |

**No code changes needed** for these default behaviors.

### Opting Out

If you need to keep the old appearance temporarily:

```swift
// Opt out of automatic glass for a specific bar
navigationBar.prefersLiquidGlass = false

// Opt out globally (not recommended, will be removed in iOS 27)
UIApplication.shared.prefersLiquidGlass = false
```

---

## UIKit Integration

### UILiquidGlassEffect

The new `UILiquidGlassEffect` class replaces `UIBlurEffect` for glass surfaces.

```swift
import UIKit

class GlassCardView: UIView {
    private let glassView: UIVisualEffectView

    override init(frame: CGRect) {
        let effect = UILiquidGlassEffect()
        effect.style = .regular
        glassView = UIVisualEffectView(effect: effect)

        super.init(frame: frame)

        glassView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glassView)

        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Round corners for glass effect
        glassView.layer.cornerRadius = 16
        glassView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### UIGlassButton

New dedicated button class with built-in glass appearance:

```swift
let primaryButton = UIGlassButton(type: .system)
primaryButton.setTitle("Continue", for: .normal)
primaryButton.glassStyle = .prominent
primaryButton.cornerRadius = 12

let secondaryButton = UIGlassButton(type: .system)
secondaryButton.setTitle("Cancel", for: .normal)
secondaryButton.glassStyle = .subtle
```

### Glass in Collection Views

```swift
func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "GlassCell",
        for: indexPath
    ) as! GlassCell

    // Apply glass background to cell
    cell.backgroundConfiguration = .glassConfiguration(style: .regular)
    cell.configure(with: items[indexPath.item])
    return cell
}
```

---

## SwiftUI Integration

### Basic Glass Background

```swift
struct GlassCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.liquidGlass, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

### Glass Modifier

```swift
Text("Floating Label")
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .glassBackground()  // Convenience modifier

// Equivalent to:
Text("Floating Label")
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .background(.liquidGlass, in: Capsule())
```

### Glass Style Modifier

```swift
VStack {
    Text("Prominent")
        .glassBackground()
        .glassStyle(.prominent)

    Text("Regular")
        .glassBackground()
        .glassStyle(.regular)

    Text("Subtle")
        .glassBackground()
        .glassStyle(.subtle)
}
```

### Interactive Glass

```swift
struct GlassToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                .font(.title2)
        }
        .buttonStyle(.glass)
        .glassStyle(isOn ? .prominent : .subtle)
    }
}
```

---

## Glass Styles Reference

| Style | Description | Use Case |
|-------|-------------|----------|
| `.regular` | Standard glass with balanced translucency | Cards, panels, containers |
| `.prominent` | Higher contrast glass, more visible | Buttons, interactive elements |
| `.subtle` | Low-contrast, background glass | Secondary UI, decorative |
| `.clear` | Nearly transparent, depth-response only | Overlays, gesture areas |
| `.tinted(Color)` | Glass with a color tint | Branded surfaces |

### Tinted Glass

```swift
// Apply brand color tint to glass
VStack {
    Text("Premium Feature")
}
.background(.liquidGlass)
.glassStyle(.tinted(.blue))

// UIKit equivalent
let effect = UILiquidGlassEffect()
effect.style = .tinted
effect.tintColor = .systemBlue
```

---

## Navigation Bar Customization

```swift
// ✅ iOS 26 — Glass navigation bar with custom tint
let appearance = UINavigationBarAppearance()
appearance.configureWithLiquidGlass()
appearance.glassTintColor = .systemBlue.withAlphaComponent(0.1)
appearance.titleTextAttributes = [
    .foregroundColor: UIColor.label
]

navigationController?.navigationBar.standardAppearance = appearance
navigationController?.navigationBar.scrollEdgeAppearance = appearance
```

### SwiftUI Navigation with Glass

```swift
NavigationStack {
    ContentView()
        .navigationTitle("Home")
        .toolbarBackground(.liquidGlass, for: .navigationBar)
        .toolbarGlassStyle(.prominent, for: .navigationBar)
}
```

---

## Tab Bar Customization

```swift
// UIKit
let tabBarAppearance = UITabBarAppearance()
tabBarAppearance.configureWithLiquidGlass()
tabBar.standardAppearance = tabBarAppearance

// SwiftUI
TabView {
    // ...
}
.toolbarBackground(.liquidGlass, for: .tabBar)
```

---

## Interaction with Dark Mode

Liquid Glass automatically adapts to the color scheme:

- **Light mode**: Brighter refraction, subtle shadows underneath
- **Dark mode**: Deeper translucency, luminance-boosted edges

```swift
// Override glass appearance for specific color scheme
struct AdaptiveGlassView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        content
            .background(.liquidGlass)
            .glassStyle(colorScheme == .dark ? .prominent : .regular)
    }
}
```

---

## Performance Considerations

Liquid Glass uses GPU-based compositing. Keep these guidelines in mind:

### Dos

- ✅ Use glass on 1-3 surfaces at a time
- ✅ Prefer system glass styles over custom configurations
- ✅ Test on oldest supported devices (iPhone XS)
- ✅ Profile with Instruments → Rendering → GPU

### Don'ts

- ❌ Stack multiple glass layers (expensive compositing)
- ❌ Animate glass style changes rapidly
- ❌ Use glass on every cell in a large list
- ❌ Apply glass to off-screen views

### Fallback for Thermal Throttling

```swift
struct SmartGlassBackground: ViewModifier {
    @Environment(\.thermalState) var thermalState

    func body(content: Content) -> some View {
        if thermalState == .critical || thermalState == .serious {
            content.background(.regularMaterial)
        } else {
            content.background(.liquidGlass)
        }
    }
}

extension View {
    func smartGlassBackground() -> some View {
        modifier(SmartGlassBackground())
    }
}
```

---

## Accessibility

Liquid Glass respects accessibility settings:

- **Reduce Transparency**: Falls back to opaque backgrounds
- **Increase Contrast**: Increases glass tint opacity
- **Reduce Motion**: Disables refraction animations

```swift
// Check and adapt manually if needed
struct AccessibleGlass: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        if reduceTransparency {
            content.background(Color(.systemBackground))
        } else {
            content.background(.liquidGlass)
        }
    }
}
```

---

## Migration from UIBlurEffect

### Quick Reference

```swift
// ❌ Old — UIBlurEffect
let blur = UIBlurEffect(style: .systemMaterial)
let view = UIVisualEffectView(effect: blur)

// ✅ New — UILiquidGlassEffect
let glass = UILiquidGlassEffect()
glass.style = .regular
let view = UIVisualEffectView(effect: glass)
```

### Style Mapping

| UIBlurEffect Style | Liquid Glass Equivalent |
|-------------------|------------------------|
| `.systemUltraThinMaterial` | `.subtle` |
| `.systemThinMaterial` | `.subtle` |
| `.systemMaterial` | `.regular` |
| `.systemThickMaterial` | `.prominent` |
| `.systemChromeMaterial` | `.prominent` |

---

## Common Pitfalls

### 1. Glass on Scrolling Content

Don't apply glass backgrounds to every row in a `List`:

```swift
// ❌ Bad — Glass on every row
List(items) { item in
    Text(item.name)
        .background(.liquidGlass)  // Performance disaster
}

// ✅ Good — Glass only on the container
List(items) { item in
    Text(item.name)
}
.scrollContentBackground(.hidden)
.background(.liquidGlass)
```

### 2. Nesting Glass Views

```swift
// ❌ Bad — Nested glass
VStack {
    Text("Hello")
        .background(.liquidGlass)
}
.background(.liquidGlass)  // Double compositing

// ✅ Good — Single glass layer
VStack {
    Text("Hello")
}
.background(.liquidGlass)
```

### 3. Glass with Custom Drawing

```swift
// ❌ Bad — drawRect with glass
class CustomView: UIView {
    override func draw(_ rect: CGRect) {
        // Custom drawing conflicts with glass compositing
    }
}

// ✅ Good — Use contentView inside glass
let glassView = UIVisualEffectView(effect: UILiquidGlassEffect())
let customContent = CustomDrawingView()
glassView.contentView.addSubview(customContent)
```

---

> 📖 Back to [main guide](../README.md) | Next: [SwiftUI Changes](swiftui-changes.md)
