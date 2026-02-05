# App Intents Migration for iOS 26

> Back to [main guide](../../README.md)

Complete guide for migrating App Intents and Shortcuts integrations to iOS 26.

---

## Table of Contents

- [What's New](#whats-new)
- [Breaking Changes](#breaking-changes)
- [Migration Steps](#migration-steps)
- [New APIs](#new-apis)
- [Spotlight Integration](#spotlight-integration)
- [Siri Enhancements](#siri-enhancements)
- [Best Practices](#best-practices)

---

## What's New

iOS 26 brings significant enhancements to App Intents:

| Feature | Description | Impact |
|---------|-------------|--------|
| **Natural Language Understanding** | Enhanced Siri comprehension | High |
| **Intent Chaining** | Connect multiple intents | Medium |
| **Parameterized Shortcuts** | Dynamic parameter injection | High |
| **Visual Results** | Rich result snippets | Medium |
| **Background Execution** | Extended background time | High |
| **Cross-App Intents** | Inter-app communication | Medium |

---

## Breaking Changes

### Removed: SiriKit Intents Framework

```swift
// ❌ iOS 25 - Old SiriKit Intents (REMOVED)
import Intents

class OrderCoffeeIntent: INIntent {
    @NSManaged var coffeeType: String?
    @NSManaged var size: String?
}

class OrderCoffeeIntentHandler: NSObject, OrderCoffeeIntentHandling {
    func handle(intent: OrderCoffeeIntent, completion: @escaping (OrderCoffeeIntentResponse) -> Void) {
        // Handle intent
        completion(OrderCoffeeIntentResponse.success(coffeeType: intent.coffeeType ?? ""))
    }
}

// ✅ iOS 26 - App Intents Framework
import AppIntents

struct OrderCoffeeIntent: AppIntent {
    static let title: LocalizedStringResource = "Order Coffee"
    static let description = IntentDescription("Order your favorite coffee")
    
    @Parameter(title: "Coffee Type")
    var coffeeType: CoffeeType
    
    @Parameter(title: "Size")
    var size: CoffeeSize
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let order = try await OrderService.shared.place(
            coffee: coffeeType,
            size: size
        )
        return .result(dialog: "Your \(size.rawValue) \(coffeeType.rawValue) is on its way!")
    }
}

enum CoffeeType: String, AppEnum {
    case latte = "Latte"
    case cappuccino = "Cappuccino"
    case americano = "Americano"
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Coffee Type")
    static let caseDisplayRepresentations: [CoffeeType: DisplayRepresentation] = [
        .latte: "Latte ☕",
        .cappuccino: "Cappuccino ☕",
        .americano: "Americano ☕"
    ]
}

enum CoffeeSize: String, AppEnum {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Size")
    static let caseDisplayRepresentations: [CoffeeSize: DisplayRepresentation] = [
        .small: "Small",
        .medium: "Medium",
        .large: "Large"
    ]
}
```

### Intent Donation Changes

```swift
// ❌ iOS 25 - Old donation pattern
let interaction = INInteraction(intent: myIntent, response: nil)
interaction.donate { error in
    // Handle error
}

// ✅ iOS 26 - New donation pattern
struct RecentOrderIntent: AppIntent, PredictableIntent {
    static let title: LocalizedStringResource = "Reorder Recent"
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$orderId)) { orderId in
            DisplayRepresentation(
                title: "Reorder \(orderId.name)",
                subtitle: "From your recent orders"
            )
        }
    }
    
    @Parameter(title: "Order")
    var orderId: OrderEntity
    
    func perform() async throws -> some IntentResult {
        // Automatically donated when performed
        try await OrderService.shared.reorder(orderId)
        return .result()
    }
}
```

---

## Migration Steps

### Step 1: Replace INIntent with AppIntent

```swift
// Create AppIntent structs for each INIntent
struct MyAppIntents: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OrderCoffeeIntent(),
            phrases: [
                "Order a \(\.$coffeeType) from \(.applicationName)",
                "Get me a \(\.$coffeeType)",
                "I want a \(\.$size) \(\.$coffeeType)"
            ],
            shortTitle: "Order Coffee",
            systemImageName: "cup.and.saucer.fill"
        )
    }
}
```

### Step 2: Define App Entities

```swift
// ✅ iOS 26 - Define entities for parameters
struct OrderEntity: AppEntity {
    let id: UUID
    let name: String
    let items: [String]
    let total: Decimal
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Order")
    static let defaultQuery = OrderEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "Total: $\(total)",
            image: .init(systemName: "bag.fill")
        )
    }
}

struct OrderEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [OrderEntity] {
        try await OrderService.shared.orders(ids: identifiers)
    }
    
    func suggestedEntities() async throws -> [OrderEntity] {
        try await OrderService.shared.recentOrders()
    }
    
    func defaultResult() async -> OrderEntity? {
        try? await OrderService.shared.lastOrder()
    }
}
```

### Step 3: Add Rich Results

```swift
struct OrderCoffeeIntent: AppIntent {
    static let title: LocalizedStringResource = "Order Coffee"
    
    @Parameter(title: "Coffee Type")
    var coffeeType: CoffeeType
    
    @Parameter(title: "Size")
    var size: CoffeeSize
    
    // ✅ iOS 26 - Rich visual results
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        let order = try await OrderService.shared.place(
            coffee: coffeeType,
            size: size
        )
        
        return .result(value: order) {
            OrderConfirmationView(order: order)
        }
    }
}

struct OrderConfirmationView: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            
            Text("Order Confirmed!")
                .font(.headline)
            
            Text("Your \(order.size) \(order.coffeeType) will be ready in ~5 minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Order #\(order.id.uuidString.prefix(8))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .glassEffect()
    }
}
```

### Step 4: Implement Intent Chaining

```swift
// ✅ iOS 26 - Chain multiple intents
struct MorningRoutineIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Morning Routine"
    
    func perform() async throws -> some IntentResult & OpensIntent {
        // First, order coffee
        let coffeeIntent = OrderCoffeeIntent()
        coffeeIntent.coffeeType = .latte
        coffeeIntent.size = .medium
        
        // Return to open next intent
        return .result(opensIntent: CheckCalendarIntent())
    }
}

struct CheckCalendarIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Today's Calendar"
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let events = try await CalendarService.shared.todayEvents()
        
        if events.isEmpty {
            return .result()
        } else {
            return .result(opensIntent: ReadEventsIntent(events: events))
        }
    }
}
```

---

## New APIs

### AssistantSchema Integration

```swift
// ✅ iOS 26 - Register with Apple Intelligence
import AssistantSchema

@AssistantSchema
struct CoffeeAppSchema: AssistantSchemaProviding {
    static var intents: [any AppIntent.Type] {
        [
            OrderCoffeeIntent.self,
            ReorderIntent.self,
            CheckOrderStatusIntent.self,
            CancelOrderIntent.self
        ]
    }
    
    static var entities: [any AppEntity.Type] {
        [
            OrderEntity.self,
            CoffeeType.self,
            StoreEntity.self
        ]
    }
}
```

### Dynamic Parameters

```swift
// ✅ iOS 26 - Dynamic options provider
struct SelectStoreIntent: AppIntent {
    static let title: LocalizedStringResource = "Select Store"
    
    @Parameter(title: "Store", optionsProvider: NearbyStoresProvider())
    var store: StoreEntity
    
    func perform() async throws -> some IntentResult {
        try await StoreService.shared.setPreferred(store)
        return .result(dialog: "Set \(store.name) as your preferred store")
    }
}

struct NearbyStoresProvider: DynamicOptionsProvider {
    func results() async throws -> [StoreEntity] {
        let location = try await LocationService.shared.current()
        return try await StoreService.shared.nearby(location: location, limit: 10)
    }
    
    func defaultResult() async -> StoreEntity? {
        try? await StoreService.shared.preferred()
    }
}
```

### Background Execution

```swift
// ✅ iOS 26 - Extended background time
struct SyncDataIntent: AppIntent {
    static let title: LocalizedStringResource = "Sync Data"
    
    // Request extended execution time
    static let isDiscoverable = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed
    
    func perform() async throws -> some IntentResult {
        try await withExtendedBackgroundExecution {
            // Long-running sync operation
            try await DataSyncService.shared.fullSync()
        }
        return .result(dialog: "Sync complete!")
    }
}

func withExtendedBackgroundExecution<T>(_ operation: () async throws -> T) async throws -> T {
    return try await withTaskGroup(of: T.self) { group in
        let task = Task {
            return try await operation()
        }
        
        // Request extended execution
        ProcessInfo.processInfo.performExpiringActivity(withReason: "App Intent Execution") { expired in
            if expired {
                task.cancel()
            }
        }
        
        return try await task.value
    }
}
```

---

## Spotlight Integration

### Indexing App Entities

```swift
// ✅ iOS 26 - Automatic Spotlight indexing
struct MenuItemEntity: AppEntity, IndexedEntity {
    let id: UUID
    let name: String
    let description: String
    let price: Decimal
    let category: String
    let imageURL: URL?
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Menu Item")
    static let defaultQuery = MenuItemQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "$\(price)",
            image: imageURL.map { .init(url: $0) }
        )
    }
    
    // Spotlight indexing
    static var attributeSet: CSSearchableItemAttributeSet.Type {
        CSSearchableItemAttributeSet.self
    }
    
    func attributeSet() -> CSSearchableItemAttributeSet {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = name
        attributes.contentDescription = description
        attributes.displayName = name
        attributes.keywords = [category, name]
        attributes.thumbnailURL = imageURL
        return attributes
    }
}

// Index on demand
struct IndexMenuIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Menu Index"
    
    func perform() async throws -> some IntentResult {
        let items = try await MenuService.shared.allItems()
        
        await withTaskGroup(of: Void.self) { group in
            for item in items {
                group.addTask {
                    try? await item.index()
                }
            }
        }
        
        return .result(dialog: "Menu index updated")
    }
}
```

---

## Siri Enhancements

### Natural Language Variants

```swift
// ✅ iOS 26 - Rich phrase support
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OrderCoffeeIntent(),
            phrases: [
                // Explicit commands
                "Order a \(\.$coffeeType) from \(.applicationName)",
                "Order \(\.$size) \(\.$coffeeType) from \(.applicationName)",
                
                // Casual requests
                "I want a \(\.$coffeeType)",
                "Get me a \(\.$coffeeType)",
                "I need coffee from \(.applicationName)",
                
                // Questions
                "Can I get a \(\.$coffeeType)?",
                "What's good at \(.applicationName)?",
                
                // Contextual
                "Same as usual from \(.applicationName)",
                "My regular order from \(.applicationName)"
            ],
            shortTitle: "Order Coffee",
            systemImageName: "cup.and.saucer.fill"
        )
    }
}
```

### Proactive Suggestions

```swift
// ✅ iOS 26 - Predictable intents for proactive suggestions
struct ReorderIntent: AppIntent, PredictableIntent {
    static let title: LocalizedStringResource = "Reorder"
    
    @Parameter(title: "Previous Order")
    var order: OrderEntity
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$order)) { order in
            DisplayRepresentation(
                title: "Reorder \(order.name)",
                subtitle: "Your last order from \(order.timestamp.formatted())",
                image: .init(systemName: "arrow.clockwise")
            )
        }
    }
    
    func perform() async throws -> some IntentResult {
        let newOrder = try await OrderService.shared.reorder(order)
        return .result(dialog: "Reordering \(order.name)")
    }
}
```

### Conversational Follow-ups

```swift
// ✅ iOS 26 - Request clarification
struct AmbiguousOrderIntent: AppIntent {
    static let title: LocalizedStringResource = "Order"
    
    @Parameter(title: "Item")
    var item: String?
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let item = item else {
            // Request clarification
            throw NeedsValueError(
                \.$item,
                dialog: "What would you like to order?",
                suggestedValues: ["Latte", "Cappuccino", "Americano"]
            )
        }
        
        // Process order
        return .result(dialog: "Ordering \(item)")
    }
}
```

---

## Best Practices

### 1. Design for Voice First

```swift
// Good: Natural, conversational responses
return .result(dialog: "Your latte is on its way! Should be ready in about 5 minutes.")

// Avoid: Technical, robotic responses
return .result(dialog: "Order ID 12345 placed successfully. ETA: 300 seconds.")
```

### 2. Provide Meaningful Suggestions

```swift
struct MenuQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [MenuItemEntity] {
        // Return relevant matches
        try await MenuService.shared.search(string)
    }
    
    func suggestedEntities() async throws -> [MenuItemEntity] {
        // Return contextually relevant suggestions
        let timeOfDay = Calendar.current.component(.hour, from: Date())
        
        if timeOfDay < 11 {
            return try await MenuService.shared.breakfastItems()
        } else if timeOfDay < 14 {
            return try await MenuService.shared.lunchItems()
        } else {
            return try await MenuService.shared.allTimeItems()
        }
    }
}
```

### 3. Handle Errors Gracefully

```swift
struct RobustOrderIntent: AppIntent {
    static let title: LocalizedStringResource = "Order"
    
    @Parameter(title: "Item")
    var item: MenuItemEntity
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let order = try await OrderService.shared.place(item)
            return .result(dialog: "Your \(item.name) is on its way!")
        } catch OrderError.outOfStock {
            return .result(dialog: "Sorry, \(item.name) is currently out of stock. Would you like something else?")
        } catch OrderError.storesClosed {
            return .result(dialog: "All stores are currently closed. Orders will resume at 6 AM.")
        } catch {
            return .result(dialog: "Something went wrong. Please try again or open the app.")
        }
    }
}
```

### 4. Test Thoroughly

```swift
// Unit test for App Intent
@Test
func testOrderCoffeeIntent() async throws {
    let intent = OrderCoffeeIntent()
    intent.coffeeType = .latte
    intent.size = .medium
    
    let result = try await intent.perform()
    
    // Verify result
    #expect(result.dialog != nil)
}

// Integration test with mock services
@Test
func testOrderCoffeeIntentIntegration() async throws {
    let mockService = MockOrderService()
    OrderService.shared = mockService
    
    let intent = OrderCoffeeIntent()
    intent.coffeeType = .cappuccino
    intent.size = .large
    
    _ = try await intent.perform()
    
    #expect(mockService.lastOrder?.coffeeType == .cappuccino)
    #expect(mockService.lastOrder?.size == .large)
}
```

---

## Migration Checklist

- [ ] Audit existing SiriKit intents
- [ ] Create AppIntent structs for each intent
- [ ] Define AppEntity types for parameters
- [ ] Implement EntityQuery for each entity
- [ ] Add AppShortcut phrases
- [ ] Implement PredictableIntent for suggestions
- [ ] Add rich visual results where appropriate
- [ ] Test with Siri and Shortcuts app
- [ ] Register with AssistantSchema
- [ ] Update documentation

---

## Related Documentation

- [SwiftUI Changes](../swiftui-changes.md)
- [Swift 6 Migration](../swift6/migration.md)
- [Complete Checklist](../checklist/complete-guide.md)
- [Apple App Intents Documentation](https://developer.apple.com/documentation/appintents)
