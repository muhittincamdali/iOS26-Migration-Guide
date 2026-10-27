# Adopting Liquid Glass

Let standard controls take on the iOS 26 design, remove what covers it, and use the glass APIs
only where a custom control needs them.

## Overview

When you build with the iOS 26 SDK, standard bars, tab bars, sheets, popovers and controls from
SwiftUI and UIKit take on Liquid Glass without code changes. Most of the work is removing things
that were added to make the old design look different. The scanner's Liquid Glass and UIKit rules
find the common ones.

### Step 1: Stop opting out

`UIDesignRequiresCompatibility` set to `YES` runs the app in the previous design. Apple describes
it as a key to use temporarily while you refine the UI, and the system ignores it when you build
for iOS 27 or later. The scanner reports it in Info.plist files and as the
`INFOPLIST_KEY_UIDesignRequiresCompatibility` build setting (`design-compatibility-mode`). Remove
it, build, and go through the screens.

### Step 2: Remove custom bar backgrounds

Apple's "Adopting Liquid Glass" guide asks you to reduce custom backgrounds in controls and
navigation elements, because they can cover the material and the scroll edge effect. The scanner
reports `configureWithOpaqueBackground()`, `barTintColor` and SwiftUI's `toolbarBackground` as
`custom-bar-background` (info). Remove them where the design allows, then check legibility over
your content.

### Step 3: Rename what iOS 26 renamed

| Deprecated in iOS 26.0                       | Replacement                 |
| -------------------------------------------- | --------------------------- |
| `UIBarButtonItem.Style.done`                 | `.prominent`                |
| `doneButtonAppearance`                       | `prominentButtonAppearance` |
| `UINavigationItem.SearchBarPlacement.inline` | `.integrated`               |
| `UIMenu.Identifier.newScene`                 | `.newItem`                  |
| `Text("a") + Text("b")`                      | `Text("\(Text("a"))b")`     |

### Step 4: Use glass on custom controls, sparingly

For a control you draw yourself, SwiftUI's glass APIs give it the same material. Keep it to the
controls that float above content; content itself stays below. This is the Liquid Glass screen of
the MigrationLab example:

```swift
Text("Content stays below; glass is for the controls that float above it.")
    .font(.headline)
    .multilineTextAlignment(.center)
    .padding(20)
    .glassEffect(.regular.tint(.blue.opacity(0.25)), in: .rect(cornerRadius: 24))

GlassEffectContainer(spacing: 16) {
    HStack(spacing: 16) {
        Button {
            withAnimation(.smooth) { isExpanded.toggle() }
        } label: {
            Image(systemName: isExpanded ? "xmark" : "paintpalette")
                .frame(width: 52, height: 52)
        }
        .glassEffect(.regular.interactive())
        .glassEffectID("toggle", in: glass)
        .accessibilityLabel(isExpanded ? "Hide tools" : "Show tools")

        if isExpanded {
            ForEach(tools, id: \.self) { tool in
                Image(systemName: tool)
                    .frame(width: 52, height: 52)
                    .glassEffect(.regular.interactive())
                    .glassEffectID(tool, in: glass)
            }
        }
    }
    .font(.title3)
}
```

- `glassEffect(_:in:)` applies the material in a shape; `.interactive()` makes it react to touches.
- `GlassEffectContainer` lets glass shapes that are close together blend, and with
  `glassEffectID(_:in:)` morph into each other when they appear or disappear.
- For buttons, `.buttonStyle(.glass)` and `.buttonStyle(.glassProminent)` are enough.

### Step 5: Test the settings people change

People can choose how Liquid Glass looks and can turn on Reduce Transparency or Reduce Motion.
Standard components adapt on their own; check your custom controls and colors with those settings
on.

## See Also

- [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- [UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility)
