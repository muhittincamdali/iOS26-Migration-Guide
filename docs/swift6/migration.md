# Swift 6 Migration Guide

Complete guide for migrating your iOS project to Swift 6, covering concurrency, type safety, and new language features.

## Table of Contents

1. [Overview](#overview)
2. [Concurrency Migration](#concurrency-migration)
3. [Data Race Safety](#data-race-safety)
4. [Sendable Conformance](#sendable-conformance)
5. [Actor Isolation](#actor-isolation)
6. [MainActor Usage](#mainactor-usage)
7. [Async/Await Patterns](#asyncawait-patterns)
8. [Type System Changes](#type-system-changes)
9. [Migration Strategies](#migration-strategies)
10. [Common Issues and Solutions](#common-issues-and-solutions)

---

## Overview

Swift 6 introduces strict concurrency checking by default, requiring explicit handling of data races and thread safety. This guide helps you migrate existing code safely.

### Key Changes

| Feature | Swift 5.10 | Swift 6 |
|---------|-----------|---------|
| Concurrency Checking | Optional | Required |
| Sendable | Warning | Error |
| Actor Isolation | Partial | Complete |
| Data Race Safety | Best Effort | Enforced |

### Compiler Flags

```swift
// Package.swift - Enable strict concurrency
let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v26)],
    products: [...],
    targets: [
        .target(
            name: "MyTarget",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
```

```bash
# Xcode Build Settings
SWIFT_STRICT_CONCURRENCY = complete
```

---

## Concurrency Migration

### Before: Completion Handler Pattern

```swift
// Old pattern with completion handlers
class NetworkManager {
    func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        URLSession.shared.dataTask(with: userURL(id: id)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func userURL(id: String) -> URL {
        URL(string: "https://api.example.com/users/\(id)")!
    }
}

// Usage
networkManager.fetchUser(id: "123") { result in
    DispatchQueue.main.async {
        switch result {
        case .success(let user):
            self.updateUI(with: user)
        case .failure(let error):
            self.showError(error)
        }
    }
}
```

### After: Async/Await Pattern

```swift
// New async/await pattern
class NetworkManager {
    func fetchUser(id: String) async throws -> User {
        let url = userURL(id: id)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func userURL(id: String) -> URL {
        URL(string: "https://api.example.com/users/\(id)")!
    }
}

// Usage
Task {
    do {
        let user = try await networkManager.fetchUser(id: "123")
        await MainActor.run {
            updateUI(with: user)
        }
    } catch {
        await MainActor.run {
            showError(error)
        }
    }
}
```

### Converting Delegates to Async

```swift
// Before: Delegate-based API
protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ picker: ImagePicker, didSelect image: UIImage)
    func imagePickerDidCancel(_ picker: ImagePicker)
}

class ImagePicker {
    weak var delegate: ImagePickerDelegate?
    
    func present() {
        // Show picker
    }
}

// After: Async API with continuation
class AsyncImagePicker {
    func pickImage() async -> UIImage? {
        await withCheckedContinuation { continuation in
            let picker = UIImagePickerController()
            let delegate = ImagePickerDelegate(continuation: continuation)
            picker.delegate = delegate
            // Present picker
        }
    }
}

private class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let continuation: CheckedContinuation<UIImage?, Never>
    
    init(continuation: CheckedContinuation<UIImage?, Never>) {
        self.continuation = continuation
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[.originalImage] as? UIImage
        continuation.resume(returning: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        continuation.resume(returning: nil)
    }
}
```

### Converting NotificationCenter

```swift
// Before: NotificationCenter with closure
class KeyboardObserver {
    private var observer: NSObjectProtocol?
    
    func startObserving(handler: @escaping (CGFloat) -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                handler(frame.height)
            }
        }
    }
    
    func stopObserving() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// After: AsyncSequence for notifications
class AsyncKeyboardObserver {
    func keyboardHeight() -> AsyncStream<CGFloat> {
        AsyncStream { continuation in
            let observer = NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    continuation.yield(frame.height)
                }
            }
            
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}

// Usage
Task {
    for await height in keyboardObserver.keyboardHeight() {
        adjustLayout(for: height)
    }
}
```

---

## Data Race Safety

### Understanding Data Races

```swift
// Data race example - UNSAFE
class Counter {
    var value = 0 // Mutable state accessed from multiple threads
    
    func increment() {
        value += 1 // Race condition!
    }
}

// Thread 1: counter.increment()
// Thread 2: counter.increment()
// Result: Undefined behavior
```

### Solution 1: Actor Isolation

```swift
// Safe: Actor provides isolation
actor Counter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        value
    }
}

// Usage - requires await
let counter = Counter()
await counter.increment()
let value = await counter.getValue()
```

### Solution 2: Sendable Types

```swift
// Make types Sendable for safe transfer
struct UserData: Sendable {
    let id: String
    let name: String
    let email: String
}

// Classes need explicit conformance
final class ImmutableConfig: Sendable {
    let apiKey: String
    let baseURL: URL
    
    init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}
```

### Solution 3: Synchronization Primitives

```swift
// Using locks for legacy code
class ThreadSafeCounter {
    private var value = 0
    private let lock = NSLock()
    
    func increment() {
        lock.lock()
        defer { lock.unlock() }
        value += 1
    }
    
    func getValue() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

// Using actors is preferred
actor ModernCounter {
    private var value = 0
    
    func increment() { value += 1 }
    var currentValue: Int { value }
}
```

---

## Sendable Conformance

### Automatic Sendable Conformance

```swift
// Structs with Sendable properties are automatically Sendable
struct Point: Sendable {
    let x: Double
    let y: Double
}

// Enums without associated values are Sendable
enum Direction: Sendable {
    case north, south, east, west
}

// Enums with Sendable associated values are Sendable
enum Result<T: Sendable>: Sendable {
    case success(T)
    case failure(Error)
}
```

### Manual Sendable Conformance

```swift
// Class must be final and have immutable stored properties
final class Configuration: Sendable {
    let timeout: TimeInterval
    let maxRetries: Int
    let baseURL: URL
    
    init(timeout: TimeInterval, maxRetries: Int, baseURL: URL) {
        self.timeout = timeout
        self.maxRetries = maxRetries
        self.baseURL = baseURL
    }
}

// Using @unchecked Sendable for types you know are safe
final class LegacyCache: @unchecked Sendable {
    private let cache = NSCache<NSString, AnyObject>()
    private let lock = NSLock()
    
    func set(_ value: AnyObject, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(value, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> AnyObject? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
}
```

### Sendable Closures

```swift
// Sendable closure requirements
func performAsync(action: @Sendable @escaping () async -> Void) {
    Task {
        await action()
    }
}

// Usage - closure must capture only Sendable values
let config = Configuration(timeout: 30, maxRetries: 3, baseURL: apiURL)
performAsync {
    await processWithConfig(config) // OK - Configuration is Sendable
}

// Error - capturing non-Sendable type
class MutableState {
    var value = 0
}
let state = MutableState()
performAsync {
    state.value += 1 // Error: Capture of non-Sendable type
}
```

---

## Actor Isolation

### Basic Actor Usage

```swift
actor UserManager {
    private var users: [String: User] = [:]
    private var activeSession: Session?
    
    func addUser(_ user: User) {
        users[user.id] = user
    }
    
    func getUser(id: String) -> User? {
        users[id]
    }
    
    func setSession(_ session: Session) {
        activeSession = session
    }
    
    var currentSession: Session? {
        activeSession
    }
}

// All calls require await
let manager = UserManager()
await manager.addUser(newUser)
let user = await manager.getUser(id: "123")
```

### Nonisolated Members

```swift
actor DataStore {
    private var items: [Item] = []
    
    // Computed from immutable data - can be nonisolated
    nonisolated let identifier: UUID
    
    // Method that doesn't access actor state
    nonisolated func validate(item: Item) -> Bool {
        !item.name.isEmpty && item.value >= 0
    }
    
    init(identifier: UUID) {
        self.identifier = identifier
    }
    
    func addItem(_ item: Item) {
        guard validate(item: item) else { return }
        items.append(item)
    }
}

// Nonisolated members don't require await
let store = DataStore(identifier: UUID())
let id = store.identifier // No await needed
let isValid = store.validate(item: item) // No await needed
```

### Actor Reentrancy

```swift
actor BankAccount {
    private var balance: Double = 0
    
    func deposit(_ amount: Double) {
        balance += amount
    }
    
    func withdraw(_ amount: Double) async throws {
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        
        // Await point - actor can be reentered
        await logTransaction(.withdrawal(amount))
        
        // Check balance again after await
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        
        balance -= amount
    }
    
    private func logTransaction(_ transaction: Transaction) async {
        // Log to external service
    }
}
```

### Global Actors

```swift
// Define custom global actor
@globalActor
actor DatabaseActor {
    static let shared = DatabaseActor()
}

// Use global actor isolation
@DatabaseActor
class DatabaseManager {
    private var connection: Connection?
    
    func connect() async throws {
        connection = try await Connection.establish()
    }
    
    func execute(_ query: String) async throws -> [Row] {
        guard let connection else {
            throw DatabaseError.notConnected
        }
        return try await connection.execute(query)
    }
}

// Functions isolated to database actor
@DatabaseActor
func performDatabaseWork() async throws {
    let manager = DatabaseManager()
    try await manager.connect()
    let results = try await manager.execute("SELECT * FROM users")
}
```

---

## MainActor Usage

### Basic MainActor Isolation

```swift
// Entire class on MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            items = try await fetchItems()
        } catch {
            self.error = error
        }
    }
    
    private func fetchItems() async throws -> [Item] {
        // Network call
        return []
    }
}
```

### Selective MainActor Isolation

```swift
class DataProcessor {
    // Only UI updates on MainActor
    @MainActor var progress: Double = 0
    @MainActor var status: String = "Ready"
    
    // Heavy processing off MainActor
    func processData(_ data: [DataPoint]) async -> ProcessedResult {
        var result = ProcessedResult()
        
        for (index, point) in data.enumerated() {
            result.add(process(point))
            
            // Update UI periodically
            if index % 100 == 0 {
                await MainActor.run {
                    progress = Double(index) / Double(data.count)
                    status = "Processing \(index)/\(data.count)"
                }
            }
        }
        
        await MainActor.run {
            progress = 1.0
            status = "Complete"
        }
        
        return result
    }
    
    private func process(_ point: DataPoint) -> ProcessedPoint {
        // CPU-intensive work
        ProcessedPoint()
    }
}
```

### MainActor and SwiftUI

```swift
// SwiftUI views are implicitly @MainActor
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .task {
            // Task inherits MainActor context
            await viewModel.loadItems()
        }
        .refreshable {
            await viewModel.loadItems()
        }
    }
}

@MainActor
@Observable
class ViewModel {
    var items: [Item] = []
    
    func loadItems() async {
        // Already on MainActor
        items = try await fetchItems()
    }
}
```

### Escaping MainActor

```swift
@MainActor
class UIController {
    func performHeavyWork() async {
        // Exit MainActor for heavy computation
        let result = await Task.detached(priority: .userInitiated) {
            await self.heavyComputation()
        }.value
        
        // Back on MainActor for UI update
        updateUI(with: result)
    }
    
    nonisolated func heavyComputation() async -> ComputationResult {
        // Runs off MainActor
        var result = ComputationResult()
        for i in 0..<1_000_000 {
            result.process(i)
        }
        return result
    }
    
    func updateUI(with result: ComputationResult) {
        // UI updates here
    }
}
```

---

## Async/Await Patterns

### Task Groups

```swift
func fetchAllUserData(userIds: [String]) async throws -> [UserData] {
    try await withThrowingTaskGroup(of: UserData.self) { group in
        for id in userIds {
            group.addTask {
                try await fetchUserData(id: id)
            }
        }
        
        var results: [UserData] = []
        for try await userData in group {
            results.append(userData)
        }
        return results
    }
}

// With limited concurrency
func fetchWithLimit(userIds: [String], maxConcurrent: Int) async throws -> [UserData] {
    try await withThrowingTaskGroup(of: UserData.self) { group in
        var iterator = userIds.makeIterator()
        var results: [UserData] = []
        
        // Start initial batch
        for _ in 0..<min(maxConcurrent, userIds.count) {
            if let id = iterator.next() {
                group.addTask { try await self.fetchUserData(id: id) }
            }
        }
        
        // Process results and add new tasks
        for try await userData in group {
            results.append(userData)
            if let id = iterator.next() {
                group.addTask { try await self.fetchUserData(id: id) }
            }
        }
        
        return results
    }
}
```

### AsyncSequence

```swift
// Custom AsyncSequence
struct CountdownSequence: AsyncSequence {
    typealias Element = Int
    
    let start: Int
    let interval: Duration
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var current: Int
        let interval: Duration
        
        mutating func next() async -> Int? {
            guard current > 0 else { return nil }
            try? await Task.sleep(for: interval)
            defer { current -= 1 }
            return current
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(current: start, interval: interval)
    }
}

// Usage
for await count in CountdownSequence(start: 10, interval: .seconds(1)) {
    print("\(count)...")
}
print("Liftoff!")
```

### Async Property Wrapper

```swift
@propertyWrapper
struct AsyncLazy<T: Sendable> {
    private let computation: @Sendable () async throws -> T
    private var cached: T?
    
    init(wrappedValue: @autoclosure @escaping @Sendable () async throws -> T) {
        self.computation = wrappedValue
    }
    
    var wrappedValue: T {
        get async throws {
            if let cached {
                return cached
            }
            let value = try await computation()
            return value
        }
    }
}

// Usage
class ResourceManager {
    @AsyncLazy var configuration = await loadConfiguration()
    
    func loadConfiguration() async -> Configuration {
        // Load from network or disk
        Configuration()
    }
}
```

---

## Type System Changes

### Typed Throws

```swift
// Swift 6: Typed throws
enum NetworkError: Error {
    case noConnection
    case timeout
    case invalidResponse
}

func fetchData() throws(NetworkError) -> Data {
    guard isConnected else {
        throw .noConnection
    }
    // ...
    return Data()
}

// Caller knows exact error type
do {
    let data = try fetchData()
} catch .noConnection {
    showOfflineMessage()
} catch .timeout {
    retryWithLongerTimeout()
} catch .invalidResponse {
    reportBug()
}
```

### Opaque Parameter Types

```swift
// Before: Generic constraint
func process<T: Collection>(items: T) where T.Element == Int {
    // ...
}

// Swift 6: Opaque parameter type
func process(items: some Collection<Int>) {
    // Same functionality, cleaner syntax
}

// Multiple opaque types
func combine(
    first: some Collection<Int>,
    second: some Collection<Int>
) -> [Int] {
    Array(first) + Array(second)
}
```

### Pack Expansion

```swift
// Variadic generics
func concatenate<each T: CustomStringConvertible>(_ values: repeat each T) -> String {
    var result = ""
    repeat result += (each values).description
    return result
}

// Usage
let message = concatenate("Hello", 42, true, 3.14)
// "Hello42true3.14"

// Tuple transformation
func transform<each T, each U>(
    _ inputs: repeat each T,
    using transforms: repeat (each T) -> each U
) -> (repeat each U) {
    (repeat (each transforms)(each inputs))
}
```

---

## Migration Strategies

### Gradual Migration Approach

```swift
// Step 1: Enable warnings in Swift 5.10
// Build Settings: SWIFT_STRICT_CONCURRENCY = targeted

// Step 2: Fix warnings module by module
// Start with leaf modules (no dependencies)

// Step 3: Mark known-safe types
extension LegacyType: @unchecked Sendable {}

// Step 4: Convert to async/await
// Use continuation bridges for callbacks

// Step 5: Enable complete checking
// SWIFT_STRICT_CONCURRENCY = complete
```

### Bridge Patterns

```swift
// Bridge callback to async
extension LegacyAPI {
    func fetchAsync() async throws -> Result {
        try await withCheckedThrowingContinuation { continuation in
            fetch { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: APIError.unknown)
                }
            }
        }
    }
}

// Bridge async to callback
extension ModernAPI {
    func fetchWithCallback(completion: @escaping (Result<Data, Error>) -> Void) {
        Task {
            do {
                let data = try await fetch()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
```

### Testing Migration

```swift
// Test async code
func testAsyncFetch() async throws {
    let api = ModernAPI()
    let result = try await api.fetch()
    XCTAssertNotNil(result)
}

// Test actor isolation
func testActorIsolation() async {
    let counter = Counter()
    
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<1000 {
            group.addTask {
                await counter.increment()
            }
        }
    }
    
    let finalValue = await counter.getValue()
    XCTAssertEqual(finalValue, 1000)
}
```

---

## Common Issues and Solutions

### Issue: Sendable Closure Capturing Self

```swift
// Problem
class ViewController {
    var data: [String] = []
    
    func refresh() {
        Task {
            data = await fetchData() // Error: self not Sendable
        }
    }
}

// Solution 1: Make class MainActor isolated
@MainActor
class ViewController {
    var data: [String] = []
    
    func refresh() {
        Task {
            data = await fetchData() // OK
        }
    }
}

// Solution 2: Capture only what's needed
class ViewController {
    var data: [String] = []
    
    func refresh() {
        Task { @MainActor [weak self] in
            self?.data = await fetchData()
        }
    }
}
```

### Issue: Actor Reentrancy Bugs

```swift
// Problem: State changes during await
actor Account {
    var balance: Double = 100
    
    func withdraw(_ amount: Double) async throws {
        guard balance >= amount else { throw Error.insufficient }
        await logWithdrawal(amount) // State might change here!
        balance -= amount // Might overdraw!
    }
}

// Solution: Check state after await
actor Account {
    var balance: Double = 100
    
    func withdraw(_ amount: Double) async throws {
        guard balance >= amount else { throw Error.insufficient }
        await logWithdrawal(amount)
        guard balance >= amount else { throw Error.insufficient } // Re-check
        balance -= amount
    }
}
```

### Issue: Deadlock with MainActor

```swift
// Problem: Blocking MainActor
@MainActor
func problematic() {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await doWork()
        semaphore.signal()
    }
    semaphore.wait() // Deadlock! MainActor is blocked
}

// Solution: Use async throughout
@MainActor
func correct() async {
    await doWork()
    // Continue after work is done
}
```

### Issue: Protocol Conformance

```swift
// Problem: Protocol doesn't support async
protocol DataProvider {
    func getData() -> Data
}

// Solution 1: Make protocol async
protocol AsyncDataProvider {
    func getData() async -> Data
}

// Solution 2: Bridge in conformance
class NetworkProvider: DataProvider {
    private var cachedData: Data?
    
    func getData() -> Data {
        cachedData ?? Data()
    }
    
    func refreshData() async {
        cachedData = await fetchFromNetwork()
    }
}
```

---

## Summary

Swift 6 migration requires:

1. **Understanding concurrency model** - Actors, Sendable, isolation
2. **Converting callbacks to async** - Use continuations
3. **Making types Sendable** - Audit all cross-boundary types
4. **Proper MainActor usage** - UI code isolation
5. **Testing thoroughly** - Concurrency bugs are subtle

Take a gradual approach, starting with warnings before enabling strict mode.

---

## Related Documentation

- [SwiftUI New APIs](../swiftui/new-apis.md)
- [Complete Migration Checklist](../checklist/complete-guide.md)
- [Common Issues Guide](../../examples/common-issues/README.md)
