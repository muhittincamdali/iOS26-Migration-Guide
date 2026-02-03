# SwiftUI Changes in iOS 26

> Back to [main guide](../README.md)

This document covers all SwiftUI changes, new modifiers, deprecations, and migration patterns for iOS 26.

---

## Table of Contents

- [New Modifiers](#new-modifiers)
- [Navigation Updates](#navigation-updates)
- [Scene Lifecycle](#scene-lifecycle)
- [Observable Migration](#observable-migration)
- [Animation Changes](#animation-changes)
- [New Views](#new-views)
- [Layout Updates](#layout-updates)
- [Deprecations](#deprecations)
- [Environment Changes](#environment-changes)
- [Previews in Xcode 27](#previews-in-xcode-27)

---

## New Modifiers

### `.presentation(isPresented:style:content:)`

Unified presentation API replacing `.sheet`, `.fullScreenCover`, and `.popover`.

```swift
// ❌ iOS 25 — Three different modifiers
.sheet(isPresented: $showSheet) { SheetView() }
.fullScreenCover(isPresented: $showCover) { CoverView() }
.popover(isPresented: $showPopover) { PopoverView() }

// ✅ iOS 26 — One unified API
.presentation(isPresented: $showSheet, style: .sheet) { SheetView() }
.presentation(isPresented: $showCover, style: .fullScreen) { CoverView() }
.presentation(isPresented: $showPopover, style: .popover) { PopoverView() }
```

Available styles:
- `.sheet` — Standard bottom sheet
- `.fullScreen` — Full screen modal
- `.popover` — Popover (iPad/Mac) or sheet (iPhone)
- `.inspector` — Side panel inspector
- `.glass` — Liquid Glass floating panel (new)

### `.glassBackground()`

Convenience modifier for Liquid Glass backgrounds.

```swift
Text("Status: Active")
    .padding()
    .glassBackground()
    .glassStyle(.prominent)
```

### `.contentMargins(_:for:)`

Fine-grained control over content margins per edge.

```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
.contentMargins(.horizontal, 20, for: .scrollContent)
.contentMargins(.vertical, 12, for: .scrollIndicators)
```

### `.meshGradient`

Native mesh gradient support for complex gradient effects.

```swift
Rectangle()
    .fill(
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                .red, .orange, .yellow,
                .green, .blue, .purple,
                .mint, .cyan, .indigo
            ]
        )
    )
    .frame(height: 200)
```

### `.visualEffect` Enhancements

```swift
// ✅ iOS 26 — Access to scroll position in visual effects
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemCard(item: item)
                .visualEffect { content, proxy in
                    content
                        .scaleEffect(proxy.isVisible ? 1 : 0.8)
                        .opacity(proxy.isVisible ? 1 : 0.3)
                        .blur(radius: proxy.isVisible ? 0 : 5)
                }
        }
    }
}
```

---

## Navigation Updates

### Type-Safe Navigation Paths

```swift
// ✅ iOS 26 — Improved NavigationPath with type safety
@Observable
class Router {
    var path = NavigationPath()

    func showDetail(_ item: Item) {
        path.append(item)
    }

    func showSettings() {
        path.append(Route.settings)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum Route: Hashable {
    case settings
    case profile(userId: String)
    case detail(Item)
}

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .settings:
                        SettingsView()
                    case .profile(let userId):
                        ProfileView(userId: userId)
                    case .detail(let item):
                        DetailView(item: item)
                    }
                }
        }
        .environment(router)
    }
}
```

### NavigationSplitView Improvements

```swift
// ✅ iOS 26 — Preferred column widths with glass sidebar
NavigationSplitView(preferredCompactColumn: $selectedColumn) {
    SidebarView()
        .navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 350)
        .toolbarBackground(.liquidGlass, for: .navigationBar)
} content: {
    ContentListView()
} detail: {
    DetailView()
}
.navigationSplitViewStyle(.prominentDetail)
```

---

## Scene Lifecycle

### New Scene Phase Callbacks

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onScenePhase(.active) {
            print("App became active")
            refreshContent()
        }
        .onScenePhase(.inactive) {
            print("App inactive")
        }
        .onScenePhase(.background) {
            print("App in background")
            saveState()
        }
    }
}
```

### Window Management

```swift
// ✅ iOS 26 — Open specific windows programmatically
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WindowGroup("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.glass)  // Liquid Glass window chrome
        .defaultSize(width: 400, height: 600)
    }
}

// Open from anywhere
struct ContentView: View {
    @Environment(\.openWindow) var openWindow

    var body: some View {
        Button("Open Settings") {
            openWindow(id: "settings")
        }
    }
}
```

---

## Observable Migration

### From `ObservableObject` to `@Observable`

```swift
// ❌ iOS 25 — Deprecated pattern
class Store: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false

    func fetch() async {
        isLoading = true
        items = await api.fetchItems()
        isLoading = false
    }
}

struct ListView: View {
    @StateObject var store = Store()

    var body: some View {
        List(store.items) { item in
            Text(item.name)
        }
        .overlay {
            if store.isLoading { ProgressView() }
        }
    }
}

// ✅ iOS 26 — Modern pattern
@Observable
class Store {
    var items: [Item] = []
    var isLoading = false

    func fetch() async {
        isLoading = true
        items = await api.fetchItems()
        isLoading = false
    }
}

struct ListView: View {
    @State var store = Store()

    var body: some View {
        List(store.items) { item in
            Text(item.name)
        }
        .overlay {
            if store.isLoading { ProgressView() }
        }
    }
}
```

### Environment Injection

```swift
// ❌ iOS 25
@EnvironmentObject var settings: Settings

// ✅ iOS 26
@Environment(Settings.self) var settings
```

---

## Animation Changes

### Declarative Animation Overhaul

```swift
// ✅ iOS 26 — Animation phases
struct PulseView: View {
    @State private var phase = AnimationPhase.start

    var body: some View {
        Circle()
            .fill(.blue)
            .phaseAnimator([
                AnimationPhase(scale: 1, opacity: 1),
                AnimationPhase(scale: 1.2, opacity: 0.7),
                AnimationPhase(scale: 1, opacity: 1)
            ]) { content, phase in
                content
                    .scaleEffect(phase.scale)
                    .opacity(phase.opacity)
            } animation: { phase in
                .easeInOut(duration: 0.8)
            }
    }
}
```

### Keyframe Animations

```swift
// ✅ iOS 26 — Keyframe animations
struct BounceView: View {
    @State private var trigger = false

    var body: some View {
        Image(systemName: "bell.fill")
            .font(.largeTitle)
            .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
                content
                    .scaleEffect(value.scale)
                    .rotationEffect(value.rotation)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.2, duration: 0.2)
                    SpringKeyframe(1.0, duration: 0.2)
                }
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(.degrees(-15), duration: 0.1)
                    LinearKeyframe(.degrees(15), duration: 0.1)
                    LinearKeyframe(.zero, duration: 0.15)
                }
            }
    }
}
```

---

## New Views

### `GlassCard`

```swift
GlassCard {
    VStack(alignment: .leading) {
        Label("Weather", systemImage: "sun.max.fill")
            .font(.headline)
        Text("72°F — Sunny")
            .font(.title)
    }
}
```

### `MeshGradient` as Standalone View

```swift
MeshGradient(
    width: 4, height: 4,
    points: generatePoints(),
    colors: generateColors()
)
.ignoresSafeArea()
```

### Enhanced `ContentUnavailableView`

```swift
ContentUnavailableView {
    Label("No Results", systemImage: "magnifyingglass")
} description: {
    Text("Try a different search term.")
} actions: {
    Button("Clear Search") { searchText = "" }
        .buttonStyle(.glass)
}
```

---

## Layout Updates

### `ViewThatFits` Improvements

```swift
// ✅ iOS 26 — Priority-based fitting
ViewThatFits(in: .horizontal) {
    HStack {
        Image(systemName: icon)
        Text(title)
        Text(subtitle)
    }

    HStack {
        Image(systemName: icon)
        Text(title)
    }

    Image(systemName: icon)
}
```

### `Grid` Enhancements

```swift
Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
    GridRow {
        Text("Name")
            .gridColumnAlignment(.trailing)
        TextField("Enter name", text: $name)
    }
    GridRow {
        Text("Email")
        TextField("Enter email", text: $email)
    }
    GridRow {
        Color.clear
            .gridCellUnsizedAxes(.horizontal)
        Button("Submit") { submit() }
            .buttonStyle(.glass)
    }
}
```

---

## Deprecations

| Deprecated | Replacement | Notes |
|-----------|-------------|-------|
| `NavigationView` | `NavigationStack` / `NavigationSplitView` | Removed in iOS 26 |
| `.navigationBarTitle` | `.navigationTitle` | Removed |
| `@ObservedObject` | Direct observation | Deprecated |
| `@StateObject` | `@State` with `@Observable` | Deprecated |
| `@EnvironmentObject` | `@Environment` | Deprecated |
| `@Published` | `@Observable` macro | Deprecated |
| `.background(_:in:)` shape | `.fill` + `.background` | Deprecated |
| `AnyView` in lazy containers | Concrete types | Compile error |
| `.sheet(item:)` | `.presentation(item:style:)` | Deprecated |
| `GeometryReader` (some uses) | `Layout` protocol | Recommended |

---

## Environment Changes

### New Environment Values

```swift
@Environment(\.thermalState) var thermalState
@Environment(\.preferredGlassStyle) var glassStyle
@Environment(\.displayScale) var displayScale
@Environment(\.scrollPosition) var scrollPosition
```

### Custom Environment with `@Observable`

```swift
@Observable
class Theme {
    var primaryColor: Color = .blue
    var cornerRadius: CGFloat = 12
}

// Inject
ContentView()
    .environment(Theme())

// Read
struct StyledButton: View {
    @Environment(Theme.self) var theme

    var body: some View {
        Button("Tap Me") { }
            .tint(theme.primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
}
```

---

## Previews in Xcode 27

### On-Device Previews

```swift
#Preview("Home", traits: .device) {
    HomeView()
        .environment(Store.preview)
}

#Preview("Settings", traits: .fixedLayout(width: 375, height: 812)) {
    SettingsView()
}
```

### Preview with State

```swift
#Preview("Counter") {
    @Previewable @State var count = 0

    VStack {
        Text("Count: \(count)")
        Button("Increment") { count += 1 }
    }
}
```

### Preview Collections

```swift
#Preview("Buttons", traits: .sizeThatFitsLayout) {
    VStack(spacing: 16) {
        Button("Glass") { }.buttonStyle(.glass)
        Button("Bordered") { }.buttonStyle(.bordered)
        Button("Plain") { }.buttonStyle(.plain)
    }
    .padding()
}
```

---

> 📖 Back to [main guide](../README.md) | Next: [UIKit Changes](uikit-changes.md)
