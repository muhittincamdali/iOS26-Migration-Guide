# Testing in iOS 26

> Back to [main guide](../README.md)

iOS 26 and Xcode 27 bring major improvements to testing, including Swift Testing integration, parallel execution by default, and built-in snapshot testing.

---

## Table of Contents

- [Parallel Testing by Default](#parallel-testing-by-default)
- [Swift Testing Integration](#swift-testing-integration)
- [Snapshot Testing Built-In](#snapshot-testing-built-in)
- [Performance Testing Updates](#performance-testing-updates)
- [UI Testing Improvements](#ui-testing-improvements)
- [Migration from XCTest](#migration-from-xctest)

---

## Parallel Testing by Default

Xcode 27 runs all XCTest cases in parallel by default. This can surface hidden dependencies between tests.

### Opting Out for Specific Suites

```swift
class OrderedTests: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        let suite = super.defaultTestSuite
        suite.executionMode = .serial
        return suite
    }

    func test01_setup() { /* runs first */ }
    func test02_verify() { /* runs second */ }
}
```

### Isolating Shared State

```swift
// ❌ Breaks in parallel — shared mutable state
class DatabaseTests: XCTestCase {
    static let db = TestDatabase()

    func testInsert() {
        Self.db.insert(item)  // Race condition!
    }
}

// ✅ Each test gets its own instance
class DatabaseTests: XCTestCase {
    var db: TestDatabase!

    override func setUp() async throws {
        db = try await TestDatabase.createTemporary()
    }

    override func tearDown() async throws {
        try await db.destroy()
    }

    func testInsert() {
        db.insert(item)  // Safe — isolated instance
    }
}
```

---

## Swift Testing Integration

The Swift Testing framework is fully integrated into Xcode 27.

### Basic Tests

```swift
import Testing

@Suite("Cart Operations")
struct CartTests {
    @Test("Adding item increases count")
    func addItem() {
        var cart = Cart()
        cart.add(Item(name: "Widget", price: 9.99))
        #expect(cart.items.count == 1)
    }

    @Test("Empty cart has zero total")
    func emptyTotal() {
        let cart = Cart()
        #expect(cart.total == 0)
    }

    @Test("Discount applied correctly", .tags(.pricing))
    func discount() {
        var cart = Cart()
        cart.add(Item(name: "Widget", price: 100))
        cart.applyDiscount(.percent(10))
        #expect(cart.total == 90)
    }
}
```

### Parameterized Tests

```swift
@Test("Validate email formats", arguments: [
    ("user@example.com", true),
    ("invalid-email", false),
    ("user@.com", false),
    ("a@b.co", true),
])
func emailValidation(email: String, isValid: Bool) {
    #expect(EmailValidator.isValid(email) == isValid)
}
```

### Async Tests

```swift
@Test("Fetch user from API")
func fetchUser() async throws {
    let service = UserService(client: MockClient())
    let user = try await service.fetch(id: "123")
    #expect(user.name == "Test User")
}

@Test("Timeout on slow response")
func timeout() async {
    let service = UserService(client: SlowClient())
    await #expect(throws: NetworkError.timeout) {
        try await service.fetch(id: "123")
    }
}
```

---

## Snapshot Testing Built-In

Xcode 27 includes native snapshot testing support.

```swift
import XCTest

class ViewSnapshotTests: XCTestCase {
    func testProfileView() throws {
        let view = ProfileView(user: .preview)
        let hosting = UIHostingController(rootView: view)
        hosting.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)

        assertSnapshot(of: hosting, as: .image)
    }

    func testDarkMode() throws {
        let view = ProfileView(user: .preview)
        let hosting = UIHostingController(rootView: view)

        assertSnapshot(
            of: hosting,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

    func testMultipleDevices() throws {
        let view = SettingsView()
        let hosting = UIHostingController(rootView: view)

        assertSnapshot(of: hosting, as: .image(on: .iPhone16))
        assertSnapshot(of: hosting, as: .image(on: .iPhone16ProMax))
        assertSnapshot(of: hosting, as: .image(on: .iPadPro13))
    }
}
```

---

## Performance Testing Updates

```swift
@Test("Sort performance", .timeLimit(.seconds(2)))
func sortPerformance() async {
    let data = (0..<100_000).map { _ in Int.random(in: 0...1_000_000) }
    var copy = data
    copy.sort()
    #expect(copy == data.sorted())
}

// XCTest style — still supported
class PerformanceTests: XCTestCase {
    func testFetchSpeed() {
        let service = DataService()
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            _ = service.processLargeDataset()
        }
    }
}
```

---

## UI Testing Improvements

```swift
class OnboardingUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testOnboardingFlow() {
        // iOS 26 — Faster element queries
        let welcomeTitle = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 3))

        app.buttons["Get Started"].tap()
        app.buttons["Continue"].tap()
        app.buttons["Done"].tap()

        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }
}
```

---

## Migration from XCTest

### Side-by-Side

XCTest and Swift Testing can coexist in the same target. Migrate incrementally.

```swift
// These can live in the same test target:

// XCTest (existing)
class LegacyTests: XCTestCase {
    func testSomething() { XCTAssertTrue(true) }
}

// Swift Testing (new)
@Suite struct ModernTests {
    @Test func something() { #expect(true) }
}
```

### Cheat Sheet

| XCTest | Swift Testing |
|--------|--------------|
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertThrowsError` | `#expect(throws:)` |
| `XCTestCase` | `@Suite struct` |
| `func testX()` | `@Test func x()` |
| `setUp()` | `init()` |
| `tearDown()` | `deinit` |

---

> 📖 Back to [main guide](../README.md) | Next: [Checklist](checklist.md)
