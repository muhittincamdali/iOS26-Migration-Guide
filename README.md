# 🚀 iOS 26 Migration Guide

[![Stars](https://img.shields.io/github/stars/muhittincamdali/iOS26-Migration-Guide?style=flat-square)](https://github.com/muhittincamdali/iOS26-Migration-Guide/stargazers)
[![Forks](https://img.shields.io/github/forks/muhittincamdali/iOS26-Migration-Guide?style=flat-square)](https://github.com/muhittincamdali/iOS26-Migration-Guide/network/members)
[![License](https://img.shields.io/github/license/muhittincamdali/iOS26-Migration-Guide?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](CONTRIBUTING.md)

**The comprehensive, community-driven guide for migrating your apps to iOS 26, Xcode 27, and Swift 6.2.**

Whether you're maintaining a legacy UIKit codebase or building with SwiftUI, this guide covers every breaking change, new API, and best practice you need to know.

---

## 📑 Table of Contents

- [Overview: What's New in iOS 26](#overview-whats-new-in-ios-26)
- [Breaking Changes](#breaking-changes)
- [Migration Checklist](#migration-checklist)
- [Liquid Glass](#liquid-glass)
- [SwiftUI Changes](#swiftui-changes)
- [UIKit Changes](#uikit-changes)
- [Swift 6.2 Features](#swift-62-features)
- [Xcode 27](#xcode-27)
- [App Intents & Shortcuts](#app-intents--shortcuts)
- [WidgetKit Changes](#widgetkit-changes)
- [Core Data → SwiftData Migration](#core-data--swiftdata-migration)
- [Networking Changes](#networking-changes)
- [Privacy & Security Updates](#privacy--security-updates)
- [Testing: New XCTest Features](#testing-new-xctest-features)
- [Performance Tips](#performance-tips)
- [Migration Timeline](#migration-timeline)
- [Resources](#resources)
- [Contributing](#contributing)

---

## Overview: What's New in iOS 26

iOS 26 is one of the largest platform updates in recent years. Here's the big picture:

| Area | Headline Change |
|------|----------------|
| **Design** | Liquid Glass material system across all controls |
| **SwiftUI** | New scene lifecycle, improved navigation, declarative animations overhaul |
| **UIKit** | Automatic Liquid Glass adoption for bars, new trait system additions |
| **Swift** | 6.2 with typed throws, noncopyable generics, ownership refinements |
| **Xcode** | 27.0 with unified build system, live previews on-device |
| **Data** | SwiftData 2.0 with migration tooling from Core Data |
| **Privacy** | App Tracking Transparency v2, mandatory privacy nutrition labels update |
| **Widgets** | Interactive widget controls, Live Activity improvements |
| **Intents** | App Intents replaces SiriKit intents entirely |
| **Testing** | Swift Testing integration, parallel XCTest by default |

### Minimum Requirements

- **Xcode 27.0** (requires macOS 16)
- **Deployment target**: iOS 26.0 (minimum for new APIs)
- **Swift**: 6.2 (ships with Xcode 27)
- **Devices**: iPhone XS and later

---

## Breaking Changes

> ⚠️ These changes **will** break existing code when compiling with the iOS 26 SDK.

### 1. `UINavigationBar` Appearance API Removal

The legacy `UINavigationBar.appearance()` global customization is removed. Use the new `UIBarAppearance` configuration per-instance.

```swift
// ❌ iOS 25 — No longer compiles
UINavigationBar.appearance().barTintColor = .systemBlue
UINavigationBar.appearance().isTranslucent = false

// ✅ iOS 26 — Per-instance configuration
let appearance = UINavigationBarAppearance()
appearance.configureWithLiquidGlass()
appearance.backgroundColor = .systemBlue
navigationController?.navigationBar.standardAppearance = appearance
navigationController?.navigationBar.scrollEdgeAppearance = appearance
```

### 2. `ObservableObject` Protocol Deprecation

`ObservableObject` and `@Published` are formally deprecated in favor of the `@Observable` macro.

```swift
// ❌ iOS 25 — Deprecated
class UserViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isLoggedIn: Bool = false
}

// ✅ iOS 26 — Use @Observable
@Observable
class UserViewModel {
    var name: String = ""
    var isLoggedIn: Bool = false
}
```

### 3. `UITableView` Removed

`UITableView` is fully removed from the SDK. Use `UICollectionView` with list configuration.

```swift
// ❌ iOS 25 — Removed
let tableView = UITableView(frame: .zero, style: .insetGrouped)

// ✅ iOS 26 — Collection view with list layout
var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
let layout = UICollectionViewCompositionalLayout.list(using: config)
let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
```

### 4. Callback-Based Concurrency APIs Removed

Many older completion-handler APIs are removed. Use their async/await equivalents.

```swift
// ❌ iOS 25 — Removed
URLSession.shared.dataTask(with: url) { data, response, error in
    // ...
}.resume()

// ✅ iOS 26 — Async/await only
let (data, response) = try await URLSession.shared.data(from: url)
```

### 5. `Codable` Synthesis Requires Explicit `CodingKeys` for Renamed Properties

The compiler no longer auto-synthesizes `CodingKeys` when property names contain underscores in certain patterns.

### 6. Minimum Deployment Target Bumped

Apps submitted to the App Store must target iOS 17.0 or later. iOS 16 deployment target is no longer accepted.

### 7. `AnyView` Performance Warning Becomes Error

Using `AnyView` in SwiftUI `List` or `LazyVStack` now produces a compile-time error, not just a warning.

```swift
// ❌ iOS 26 — Compile error in lazy contexts
LazyVStack {
    AnyView(Text("Hello"))
}

// ✅ iOS 26 — Use concrete types or @ViewBuilder
LazyVStack {
    Text("Hello")
}
```

### 8. `UIApplication.shared` Restricted in Extensions

Accessing `UIApplication.shared` in app extensions now triggers a linker error instead of a runtime crash.

### 9. `NSCoding` Removed from `UIColor`

`UIColor` no longer conforms to `NSCoding`. Use `Codable` conformance instead.

### 10. Core Data Lightweight Migration Limitations

Lightweight migration no longer supports mapping models with custom `NSEntityMigrationPolicy`. Use SwiftData's migration tooling.

---

## Migration Checklist

Use this checklist to track your migration progress. See [docs/checklist.md](docs/checklist.md) for a printable version.

- [ ] Update to Xcode 27.0
- [ ] Set deployment target to iOS 17.0+
- [ ] Audit all `UITableView` usage → replace with `UICollectionView`
- [ ] Replace `ObservableObject` with `@Observable`
- [ ] Remove `UINavigationBar.appearance()` calls
- [ ] Migrate completion handlers to async/await
- [ ] Adopt Liquid Glass for navigation and tab bars
- [ ] Update `AnyView` usage in lazy containers
- [ ] Replace SiriKit intents with App Intents
- [ ] Test with Swift 6.2 strict concurrency
- [ ] Update privacy manifest (`PrivacyInfo.xcprivacy`)
- [ ] Migrate Core Data models to SwiftData (if applicable)
- [ ] Update Widget targets for new WidgetKit APIs
- [ ] Run full test suite with parallel testing enabled
- [ ] Profile with Instruments for iOS 26 performance changes
- [ ] Submit to TestFlight for beta testing

---

## Liquid Glass

> 📖 **Deep Dive**: [docs/liquid-glass.md](docs/liquid-glass.md)

Liquid Glass is the new design paradigm in iOS 26. It replaces the frosted-glass blur with a dynamic, depth-aware translucent material.

### Automatic Adoption

UIKit automatically applies Liquid Glass to standard bars:

```swift
// Navigation bars, tab bars, and toolbars get Liquid Glass
// automatically when compiled with iOS 26 SDK.
// No code changes needed for default behavior.
```

### Custom Views with Liquid Glass

```swift
// ❌ iOS 25 — UIVisualEffectView with blur
let blurEffect = UIBlurEffect(style: .systemMaterial)
let blurView = UIVisualEffectView(effect: blurEffect)
view.addSubview(blurView)

// ✅ iOS 26 — Liquid Glass material
let glassEffect = UILiquidGlassEffect()
let glassView = UIVisualEffectView(effect: glassEffect)
glassView.glassStyle = .regular
view.addSubview(glassView)
```

### SwiftUI Liquid Glass

```swift
// ❌ iOS 25
Text("Hello")
    .background(.ultraThinMaterial)

// ✅ iOS 26
Text("Hello")
    .background(.liquidGlass)
    .glassStyle(.regular)
```

### Glass Styles

| Style | Use Case |
|-------|----------|
| `.regular` | Standard translucent surface |
| `.prominent` | Higher contrast, foreground elements |
| `.subtle` | Background accents, minimal presence |
| `.clear` | Transparent with depth response |

---

## SwiftUI Changes

> 📖 **Deep Dive**: [docs/swiftui-changes.md](docs/swiftui-changes.md)

### New Modifiers

#### `.presentationStyle(_:)`

Replaces `.sheet`, `.fullScreenCover`, and `.popover` with a unified API.

```swift
// ❌ iOS 25 — Separate modifiers
.sheet(isPresented: $showSettings) { SettingsView() }
.fullScreenCover(isPresented: $showOnboarding) { OnboardingView() }

// ✅ iOS 26 — Unified presentation
.presentation(isPresented: $showSettings, style: .sheet) {
    SettingsView()
}
.presentation(isPresented: $showOnboarding, style: .fullScreen) {
    OnboardingView()
}
```

#### `.meshGradient`

Native mesh gradient support.

```swift
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
```

### NavigationStack Updates

```swift
// ❌ iOS 25 — navigationDestination with Hashable
.navigationDestination(for: String.self) { value in
    DetailView(id: value)
}

// ✅ iOS 26 — Type-safe navigation with @NavigationPath
@NavigationPath var path

NavigationStack(path: $path) {
    List(items) { item in
        NavigationLink(value: item) {
            Text(item.title)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}
```

### New Scene Lifecycle

```swift
// ✅ iOS 26 — Scene phase callbacks
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onScenePhase(.active) {
            refreshData()
        }
        .onScenePhase(.background) {
            saveState()
        }
    }
}
```

### Deprecations

| Deprecated | Replacement |
|-----------|-------------|
| `NavigationView` | `NavigationStack` / `NavigationSplitView` |
| `.navigationBarTitle` | `.navigationTitle` |
| `@ObservedObject` | Direct observation with `@Observable` |
| `@EnvironmentObject` | `@Environment` with `@Observable` |
| `.background(_:in:)` shape variant | `.fill` + `.background` |

---

## UIKit Changes

> 📖 **Deep Dive**: [docs/uikit-changes.md](docs/uikit-changes.md)

### New APIs

#### `UIUpdateLink`

Replaces `CADisplayLink` for UI-driven animations.

```swift
// ❌ iOS 25
let displayLink = CADisplayLink(target: self, selector: #selector(update))
displayLink.add(to: .main, forMode: .common)

// ✅ iOS 26
let updateLink = UIUpdateLink(view: myView) { link, info in
    // Update at display refresh rate
    myView.center.x += velocity * info.modelTime
}
updateLink.isEnabled = true
```

#### `UIGlassButton`

New button style with built-in Liquid Glass appearance.

```swift
let button = UIGlassButton(type: .system)
button.setTitle("Continue", for: .normal)
button.glassStyle = .prominent
button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
```

### Deprecated APIs

| Deprecated | Replacement | Deadline |
|-----------|-------------|----------|
| `UITableView` | `UICollectionView` with list layout | iOS 27 removal |
| `UIAlertView` remnants | `UIAlertController` | Removed |
| `UIActionSheet` remnants | `UIAlertController` | Removed |
| `UINavigationBar.appearance()` | `UINavigationBarAppearance` | Removed |
| `UITabBar.appearance()` | `UITabBarAppearance` | Removed |
| `CADisplayLink` | `UIUpdateLink` | iOS 28 |
| `UIScreen.main` | `UIWindowScene`-based screen access | Removed |

### Trait System Additions

```swift
// ✅ iOS 26 — New traits
class MyViewController: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.preferredGlassStyle != previousTraitCollection?.preferredGlassStyle {
            updateGlassAppearance()
        }
    }
}

// ✅ iOS 26 — Register for specific trait changes
registerForTraitChanges([UITraitPreferredGlassStyle.self]) { (self: Self, _) in
    self.updateGlassAppearance()
}
```

---

## Swift 6.2 Features

> 📖 **Deep Dive**: [docs/swift-6.2.md](docs/swift-6.2.md)

### Typed Throws

Functions can now declare the specific error types they throw.

```swift
// ❌ Swift 6.1 — Untyped throws
func fetchUser(id: String) throws -> User {
    throw NetworkError.notFound
}

// ✅ Swift 6.2 — Typed throws
func fetchUser(id: String) throws(NetworkError) -> User {
    throw .notFound
}

// Caller gets precise error type
do {
    let user = try fetchUser(id: "123")
} catch {
    // error is NetworkError, not any Error
    switch error {
    case .notFound: handleNotFound()
    case .timeout: retry()
    }
}
```

### Noncopyable Generics

```swift
// ✅ Swift 6.2 — Generic constraints with ~Copyable
struct UniqueResource: ~Copyable {
    let handle: Int

    consuming func release() {
        close(handle)
    }

    deinit {
        close(handle)
    }
}

func process<T: ~Copyable>(_ resource: consuming T) {
    // T might be noncopyable
}
```

### Ownership Refinements

```swift
// ✅ Swift 6.2 — Explicit borrowing and consuming
func display(borrowing name: String) {
    print("Hello, \(name)")
}

func archive(consuming data: Data) {
    storage.write(data)
    // data is consumed, can't be used after this
}
```

### Strict Concurrency by Default

Swift 6.2 enables strict concurrency checking by default in new projects.

```swift
// ❌ Warning in 6.1, Error in 6.2
class Cache {
    var items: [String: Any] = [:] // Not Sendable!
}

// ✅ Swift 6.2 — Make it Sendable
final class Cache: Sendable {
    let items: LockIsolated<[String: Any]>

    init() {
        items = LockIsolated([:])
    }
}
```

### `consuming` and `borrowing` Parameter Modifiers on Closures

```swift
// ✅ Swift 6.2
let transform: (consuming String) -> Int = { str in
    str.count
}
```

---

## Xcode 27

### Unified Build System

Xcode 27 introduces a completely rewritten build system with improved incremental compilation.

```
# Build time improvements (approximate)
┌──────────────────────┬──────────┬──────────┐
│ Project Size         │ Xcode 26 │ Xcode 27 │
├──────────────────────┼──────────┼──────────┤
│ Small (< 50 files)   │ 12s      │ 8s       │
│ Medium (50-500)      │ 45s      │ 28s      │
│ Large (500+)         │ 3m 20s   │ 1m 50s   │
└──────────────────────┴──────────┴──────────┘
```

### Live Previews on Device

```swift
// ✅ Xcode 27 — Previews run directly on connected device
#Preview("Settings", traits: .device) {
    SettingsView()
        .environment(AppState())
}
```

### New Debugging Tools

- **Memory Graph Debugger 2.0**: Now shows retain cycle paths automatically
- **Thread Sanitizer**: Integrated into debug builds by default
- **Structured Logging Viewer**: Filter by subsystem, category, and level inline

### Project Configuration

```swift
// Package.swift — New swift-tools-version
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .iOS(.v26),
        .macOS(.v17)
    ],
    targets: [
        .target(name: "MyLibrary"),
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]
        )
    ]
)
```

---

## App Intents & Shortcuts

SiriKit custom intents are fully removed. Migrate to App Intents.

### Before & After

```swift
// ❌ iOS 25 — SiriKit Intent (removed)
class OrderCoffeeIntentHandler: NSObject, OrderCoffeeIntentHandling {
    func handle(intent: OrderCoffeeIntent) async -> OrderCoffeeIntentResponse {
        // ...
        return .init(code: .success, userActivity: nil)
    }
}

// ✅ iOS 26 — App Intent
struct OrderCoffee: AppIntent {
    static let title: LocalizedStringResource = "Order Coffee"
    static let description: IntentDescription = "Orders your favorite coffee."

    @Parameter(title: "Size")
    var size: CoffeeSize

    @Parameter(title: "Type")
    var type: CoffeeType

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let order = try await CoffeeService.order(size: size, type: type)
        return .result(dialog: "Ordered \(order.description)")
    }
}
```

### App Shortcuts

```swift
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OrderCoffee(),
            phrases: [
                "Order coffee with \(.applicationName)",
                "Get me a \(\.$size) \(\.$type) from \(.applicationName)"
            ],
            shortTitle: "Order Coffee",
            systemImageName: "cup.and.saucer.fill"
        )
    }
}
```

---

## WidgetKit Changes

### Interactive Widget Controls

```swift
// ✅ iOS 26 — Widgets can now contain interactive controls
struct CoffeeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "coffee", provider: Provider()) { entry in
            VStack {
                Text(entry.lastOrder)

                Button(intent: OrderCoffee(size: .medium, type: .latte)) {
                    Label("Reorder", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.glass)

                Toggle(isOn: entry.notificationsEnabled,
                       intent: ToggleNotifications()) {
                    Text("Notifications")
                }
            }
        }
    }
}
```

### Live Activity Improvements

```swift
// ✅ iOS 26 — Live Activity with animated transitions
struct DeliveryActivityView: View {
    let context: ActivityViewContext<DeliveryAttributes>

    var body: some View {
        HStack {
            ProgressView(value: context.state.progress)
                .progressViewStyle(.liquidGlass)

            Text(context.state.eta, style: .timer)
                .contentTransition(.numericText())
        }
        .activityBackgroundTint(.liquidGlass)
    }
}
```

### Widget Relevance API

```swift
// ✅ iOS 26 — Provide relevance hints to the system
struct Provider: TimelineProvider {
    func relevance() async -> WidgetRelevance<Void> {
        let entries = await fetchRelevanceData()
        return WidgetRelevance(entries.map { entry in
            WidgetRelevanceEntry(
                date: entry.date,
                relevance: .init(score: entry.score)
            )
        })
    }
}
```

---

## Core Data → SwiftData Migration

### Migration Tool

Xcode 27 includes a built-in migration assistant.

```swift
// Step 1: Define SwiftData model matching Core Data entity
@Model
class Task {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var category: Category?

    init(title: String, isCompleted: Bool = false, createdAt: Date = .now) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
```

### Coexistence Strategy

```swift
// ✅ iOS 26 — Run both stacks side by side
@main
struct MyApp: App {
    // Keep Core Data for read operations during migration
    let coreDataStack = CoreDataStack()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Task.self, Category.self]) {
            container in
            // Migrate on first launch
            MigrationCoordinator.migrateIfNeeded(
                from: coreDataStack.persistentContainer,
                to: container
            )
        }
    }
}
```

### Batch Migration

```swift
// ✅ iOS 26 — Batch migrate entities
func migrateEntities(from context: NSManagedObjectContext,
                     to modelContext: ModelContext) async throws {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDTask")
    fetchRequest.fetchBatchSize = 100

    let results = try context.fetch(fetchRequest)

    for cdTask in results {
        let task = Task(
            title: cdTask.value(forKey: "title") as? String ?? "",
            isCompleted: cdTask.value(forKey: "isCompleted") as? Bool ?? false,
            createdAt: cdTask.value(forKey: "createdAt") as? Date ?? .now
        )
        modelContext.insert(task)
    }

    try modelContext.save()
}
```

---

## Networking Changes

### `URLSession` Strict Sendable Conformance

```swift
// ❌ iOS 25 — Allowed non-Sendable in delegates
class MyDelegate: NSObject, URLSessionDelegate {
    var mutableState: [String] = [] // Not Sendable

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.performDefaultHandling, nil)
    }
}

// ✅ iOS 26 — Delegate must be Sendable
final class MyDelegate: NSObject, URLSessionDelegate, Sendable {
    let state = LockIsolated<[String]>([])

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async
        -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        return (.performDefaultHandling, nil)
    }
}
```

### HTTP/3 by Default

```swift
// ✅ iOS 26 — HTTP/3 is the default protocol
let config = URLSessionConfiguration.default
// HTTP/3 is now enabled by default
// To opt out (not recommended):
config.httpAdditionalHeaders = ["Alt-Svc": "clear"]
```

### Background Transfer Improvements

```swift
// ✅ iOS 26 — Structured concurrency for background transfers
let session = URLSession(configuration: .background(withIdentifier: "upload"))

for try await event in session.events {
    switch event {
    case .taskCompleted(let task, let error):
        print("Task \(task.taskIdentifier) completed: \(error?.localizedDescription ?? "success")")
    case .downloadFinished(let task, let location):
        moveFile(from: location, for: task)
    }
}
```

---

## Privacy & Security Updates

### App Tracking Transparency v2

```swift
// ✅ iOS 26 — Enhanced ATT with category selection
import AppTrackingTransparency

func requestTracking() async {
    let status = await ATTrackingManager.requestTrackingAuthorization(
        categories: [.analytics, .advertising]
    )

    switch status {
    case .authorized(let categories):
        // User approved specific categories
        enableTracking(for: categories)
    case .denied:
        disableAllTracking()
    case .restricted, .notDetermined:
        break
    @unknown default:
        break
    }
}
```

### Privacy Manifest Requirements

Every app must include `PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <true/>
    <key>NSPrivacyTrackingDomains</key>
    <array>
        <string>analytics.example.com</string>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeDeviceID</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <true/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

### Mandatory App Sandbox Changes

```swift
// ✅ iOS 26 — Explicit file access scoping
let url = try await showDocumentPicker()

// Must use security-scoped access
guard url.startAccessingSecurityScopedResource() else {
    throw FileError.accessDenied
}
defer { url.stopAccessingSecurityScopedResource() }

let data = try Data(contentsOf: url)
```

---

## Testing: New XCTest Features

> 📖 **Deep Dive**: [docs/testing.md](docs/testing.md)

### Parallel Testing by Default

Xcode 27 runs XCTest cases in parallel by default.

```swift
// ✅ iOS 26 — Tests run in parallel automatically
// Use serial when order matters
class OrderDependentTests: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        let suite = super.defaultTestSuite
        suite.executionMode = .serial
        return suite
    }
}
```

### Swift Testing Integration

```swift
import Testing

@Suite("User Authentication")
struct AuthTests {
    @Test("Login with valid credentials")
    func validLogin() async throws {
        let service = AuthService()
        let result = try await service.login(email: "test@example.com", password: "valid")
        #expect(result.isSuccess)
    }

    @Test("Login with invalid password", .tags(.security))
    func invalidPassword() async throws {
        let service = AuthService()
        await #expect(throws: AuthError.invalidCredentials) {
            try await service.login(email: "test@example.com", password: "wrong")
        }
    }

    @Test("Login rate limiting", arguments: 1...5)
    func rateLimiting(attempt: Int) async throws {
        let service = AuthService()
        if attempt > 3 {
            await #expect(throws: AuthError.rateLimited) {
                try await service.login(email: "test@example.com", password: "wrong")
            }
        }
    }
}
```

### Snapshot Testing Built-In

```swift
import XCTest

class SnapshotTests: XCTestCase {
    func testProfileView() throws {
        let view = ProfileView(user: .preview)
        let hosting = UIHostingController(rootView: view)

        assertSnapshot(of: hosting, as: .image(on: .iPhone16))
        assertSnapshot(of: hosting, as: .image(on: .iPhone16, traits: .dark))
    }
}
```

---

## Performance Tips

### 1. Adopt `LazyVStack` Everywhere

```swift
// ❌ Slow — Loads all views
ScrollView {
    VStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}

// ✅ Fast — Lazy loading
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### 2. Use `@Precompile` for Complex Views

```swift
// ✅ iOS 26 — Precompile hint for complex view hierarchies
@Precompile
struct DashboardView: View {
    let metrics: [Metric]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(metrics) { metric in
                    MetricCard(metric: metric)
                }
            }
        }
    }
}
```

### 3. Profile Liquid Glass Impact

Liquid Glass can be expensive on older devices. Profile accordingly:

```swift
// ✅ Conditional glass based on device capability
var glassStyle: some ShapeStyle {
    if ProcessInfo.processInfo.thermalState == .critical {
        return AnyShapeStyle(.regularMaterial)
    }
    return AnyShapeStyle(.liquidGlass)
}
```

### 4. Swift 6.2 Copy-on-Write Optimization

```swift
// ✅ Swift 6.2 — Automatic COW for large structs
struct LargeDataSet {
    var items: [DataPoint]  // COW is automatically applied

    mutating func add(_ point: DataPoint) {
        items.append(point)  // Only copies if shared
    }
}
```

### 5. Reduce View Identity Recalculations

```swift
// ❌ Causes identity changes
ForEach(items) { item in
    ItemRow(item: item)
        .id(UUID())  // New ID every render!
}

// ✅ Stable identity
ForEach(items) { item in
    ItemRow(item: item)
        .id(item.stableID)
}
```

---

## Migration Timeline

Here's a suggested timeline for migrating a medium-sized app:

```
┌─────────────────────────────────────────────────────┐
│              Suggested Migration Timeline            │
├──────────┬──────────────────────────────────────────┤
│ Week 1-2 │ 🔍 Audit & Planning                     │
│          │ • Run Xcode 27 migration assistant       │
│          │ • Catalog all deprecated API usage       │
│          │ • Estimate effort per module             │
├──────────┼──────────────────────────────────────────┤
│ Week 3-4 │ 🔧 Foundation Changes                   │
│          │ • Swift 6.2 strict concurrency fixes     │
│          │ • Replace UITableView with UICollectionView│
│          │ • Migrate ObservableObject → @Observable  │
├──────────┼──────────────────────────────────────────┤
│ Week 5-6 │ 🎨 UI Modernization                     │
│          │ • Adopt Liquid Glass materials           │
│          │ • Update navigation patterns             │
│          │ • Test on all device sizes               │
├──────────┼──────────────────────────────────────────┤
│ Week 7-8 │ 📦 Data & Networking                    │
│          │ • Core Data → SwiftData migration        │
│          │ • Async/await networking updates          │
│          │ • Privacy manifest updates               │
├──────────┼──────────────────────────────────────────┤
│ Week 9-10│ 🧪 Testing & Polish                     │
│          │ • Full test suite with parallel testing  │
│          │ • Performance profiling                  │
│          │ • Accessibility audit                    │
├──────────┼──────────────────────────────────────────┤
│ Week 11+ │ 🚀 Release                              │
│          │ • TestFlight beta                        │
│          │ • Phased rollout                         │
│          │ • Monitor crash reports                  │
└──────────┴──────────────────────────────────────────┘
```

---

## Resources

### Apple Documentation

- [iOS 26 Release Notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26-release-notes)
- [What's New in SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Swift 6.2 Evolution Proposals](https://www.swift.org/swift-evolution/)
- [Xcode 27 Release Notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes)
- [Human Interface Guidelines — Liquid Glass](https://developer.apple.com/design/human-interface-guidelines/)
- [App Intents Framework](https://developer.apple.com/documentation/appintents)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Privacy Manifest Files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)

### WWDC 26 Sessions

- Platforms State of the Union
- What's New in Swift
- What's New in SwiftUI
- Migrate to SwiftData
- Meet Liquid Glass
- Modernize Your UIKit App
- What's New in Xcode 27
- Swift Testing Deep Dive

### Community

- [Swift Forums](https://forums.swift.org)
- [iOS Dev Weekly](https://iosdevweekly.com)
- [Swift by Sundell](https://swiftbysundell.com)
- [Hacking with Swift](https://hackingwithswift.com)

---

## Contributing

Contributions are welcome! This is a community resource — if you find something missing or incorrect, please help make it better.

- 📝 **Found an error?** [Open an issue](../../issues)
- 💡 **Have a migration tip?** [Submit a PR](../../pulls)
- 💬 **Want to discuss?** [Start a discussion](../../discussions)

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

**Made with ☕ by [Muhittin Camdali](https://github.com/muhittincamdali)** — Happy migrating! 🎉
