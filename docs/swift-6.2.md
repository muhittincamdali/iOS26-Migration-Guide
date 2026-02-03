# Swift 6.2 Language Changes

> Back to [main guide](../README.md)

Swift 6.2 ships with Xcode 27 and introduces several significant language features. This guide covers what you need to know for migration.

---

## Table of Contents

- [Typed Throws](#typed-throws)
- [Noncopyable Generics](#noncopyable-generics)
- [Ownership Refinements](#ownership-refinements)
- [Strict Concurrency by Default](#strict-concurrency-by-default)
- [Closure Parameter Modifiers](#closure-parameter-modifiers)
- [Improvements to Pattern Matching](#improvements-to-pattern-matching)
- [Package Manager Changes](#package-manager-changes)

---

## Typed Throws

Functions can now declare the specific error type they throw.

### Basic Usage

```swift
enum NetworkError: Error {
    case notFound
    case timeout
    case unauthorized
    case serverError(code: Int)
}

// ✅ Swift 6.2 — Typed throws
func fetchUser(id: String) throws(NetworkError) -> User {
    guard let user = try await api.get("/users/\(id)") else {
        throw .notFound
    }
    return user
}
```

### Caller Benefits

```swift
do {
    let user = try fetchUser(id: "123")
} catch {
    // `error` is `NetworkError`, not `any Error`
    switch error {
    case .notFound:
        showNotFound()
    case .timeout:
        retry()
    case .unauthorized:
        logout()
    case .serverError(let code):
        showError(code: code)
    }
}
```

### Typed Throws in Protocols

```swift
protocol DataFetching {
    associatedtype Failure: Error
    func fetch() throws(Failure) -> Data
}

struct NetworkFetcher: DataFetching {
    func fetch() throws(NetworkError) -> Data {
        // ...
    }
}
```

### Rethrows with Typed Throws

```swift
func map<T, E: Error>(_ array: [T], transform: (T) throws(E) -> T) throws(E) -> [T] {
    var result: [T] = []
    for item in array {
        result.append(try transform(item))
    }
    return result
}
```

---

## Noncopyable Generics

Swift 6.2 expands `~Copyable` support to generic contexts.

### Noncopyable Types

```swift
struct FileHandle: ~Copyable {
    private let descriptor: Int32

    init(path: String) throws {
        descriptor = open(path, O_RDONLY)
        guard descriptor >= 0 else { throw FileError.cantOpen }
    }

    consuming func close() {
        Darwin.close(descriptor)
    }

    deinit {
        Darwin.close(descriptor)
    }
}
```

### Generic Functions with Noncopyable

```swift
// ✅ Swift 6.2 — Generic over noncopyable types
func use<T: ~Copyable>(_ resource: consuming T, work: (borrowing T) -> Void) {
    work(resource)
    // resource is consumed at end of scope
}

// Works with both copyable and noncopyable types
use(FileHandle(path: "/tmp/data")) { handle in
    // borrow handle
}
```

### Noncopyable in Collections

```swift
// ✅ Swift 6.2 — Optional noncopyable
var handle: FileHandle? = try FileHandle(path: "/tmp/log")
handle = nil  // Triggers deinit

// Result with noncopyable success
let result: Result<FileHandle, Error> = .success(try FileHandle(path: "/tmp/data"))
```

---

## Ownership Refinements

### `borrowing` and `consuming` Parameters

```swift
// Borrowing — read-only access, no copy
func display(borrowing name: String) {
    print("Hello, \(name)")
    // name is borrowed, original is untouched
}

// Consuming — takes ownership, caller can't use after
func archive(consuming data: Data) {
    storage.write(data)
    // data is consumed here
}
```

### When to Use What

| Modifier | Copy? | Caller Retains? | Use Case |
|----------|-------|-----------------|----------|
| (default) | Yes | Yes | Small values, general use |
| `borrowing` | No | Yes | Read-only access to large values |
| `consuming` | No | No | Transfer ownership, deallocation |
| `inout` | No | Yes (modified) | Mutation in place |

### Practical Example

```swift
struct ImageProcessor {
    // Borrow: just reading pixel data
    func analyze(borrowing image: LargeImage) -> ImageStats {
        return ImageStats(width: image.width, height: image.height)
    }

    // Consume: we take the image and produce a new one
    func process(consuming image: LargeImage) -> LargeImage {
        var result = image  // No copy since we own it
        result.applyFilter(.sharpen)
        return result
    }
}
```

---

## Strict Concurrency by Default

Swift 6.2 enables strict concurrency checking by default for new projects. Existing projects can opt in via build settings.

### Common Fixes

#### Non-Sendable Class

```swift
// ❌ Error in Swift 6.2
class UserCache {
    var users: [String: User] = [:]
}

// ✅ Fix 1 — Make it Sendable with actor
actor UserCache {
    var users: [String: User] = [:]

    func get(_ id: String) -> User? { users[id] }
    func set(_ id: String, user: User) { users[id] = user }
}

// ✅ Fix 2 — Sendable with lock isolation
final class UserCache: Sendable {
    private let storage = LockIsolated<[String: User]>([:])

    func get(_ id: String) -> User? { storage.value[id] }
    func set(_ id: String, user: User) { storage.withValue { $0[id] = user } }
}
```

#### Global Variables

```swift
// ❌ Error in Swift 6.2
var globalConfig = AppConfig()

// ✅ Fix — Use @MainActor or make it a constant
@MainActor var globalConfig = AppConfig()
// or
let globalConfig = AppConfig()  // If immutable
```

#### Delegate Patterns

```swift
// ❌ Error — Non-sendable closure crossing actor boundary
class MyDelegate: SomeDelegate {
    func didReceive(_ data: Data) {
        DispatchQueue.main.async {
            self.update(data)  // Self is not Sendable
        }
    }
}

// ✅ Fix — Use MainActor
@MainActor
class MyDelegate: SomeDelegate {
    nonisolated func didReceive(_ data: Data) {
        Task { @MainActor in
            self.update(data)
        }
    }
}
```

---

## Closure Parameter Modifiers

```swift
// ✅ Swift 6.2 — borrowing/consuming on closure parameters
let transform: (consuming String) -> Int = { str in
    str.count  // str is consumed
}

let inspect: (borrowing [Int]) -> Int = { array in
    array.reduce(0, +)  // array is borrowed, no copy
}
```

---

## Improvements to Pattern Matching

### Exhaustive Switch on Noncopyable Enums

```swift
enum Resource: ~Copyable {
    case file(FileHandle)
    case network(Connection)
}

func handle(consuming resource: Resource) {
    switch consume resource {
    case .file(let handle):
        handle.close()
    case .network(let conn):
        conn.disconnect()
    }
}
```

### `if let` with Consuming

```swift
var optionalHandle: FileHandle? = try FileHandle(path: "/tmp/data")

if let handle = consume optionalHandle {
    // optionalHandle is now nil
    handle.close()
}
```

---

## Package Manager Changes

### swift-tools-version: 6.2

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MyPackage", targets: ["MyPackage"])
    ],
    targets: [
        .target(name: "MyPackage"),
        .testTarget(name: "MyPackageTests", dependencies: ["MyPackage"])
    ]
)
```

### New: Dependency Scoping

```swift
// ✅ Swift 6.2 — Dependencies can be scoped to configurations
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "Logging", package: "swift-log", condition: .when(configuration: .debug))
    ]
)
```

---

> 📖 Back to [main guide](../README.md) | Next: [Testing](testing.md)
