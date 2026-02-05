<p align="center">
  <img src="https://img.shields.io/badge/iOS-26-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 26"/>
  <img src="https://img.shields.io/badge/Swift-6.2-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.2"/>
  <img src="https://img.shields.io/badge/Xcode-17-1575F9?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode 17"/>
  <img src="https://img.shields.io/badge/Liquid_Glass-Ready-00C7BE?style=for-the-badge" alt="Liquid Glass"/>
  <img src="https://img.shields.io/github/license/muhittincamdali/iOS26-Migration-Guide?style=for-the-badge" alt="License"/>
  <img src="https://img.shields.io/github/stars/muhittincamdali/iOS26-Migration-Guide?style=for-the-badge&logo=github" alt="Stars"/>
</p>

<h1 align="center">🚀 iOS 26 Migration Guide</h1>

<p align="center">
  <strong>The most comprehensive iOS 26 migration guide on the internet.</strong><br/>
  Complete with code examples, automated tools, and battle-tested migration strategies.
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-whats-new-in-ios-26">What's New</a> •
  <a href="#-migration-tools">Tools</a> •
  <a href="#-documentation">Docs</a> •
  <a href="#-examples">Examples</a>
</p>

---

## 🎯 Why This Guide?

iOS 26 is the **biggest iOS update since iOS 7**, introducing Liquid Glass design, Swift 6.2 with approachable concurrency, and Foundation Models for on-device AI. This guide provides everything you need to migrate smoothly.

```
╔══════════════════════════════════════════════════════════════════╗
║                    iOS 26 MIGRATION AT A GLANCE                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  🧊 Liquid Glass Design     → Complete UI overhaul               ║
║  ⚡ Swift 6.2 Concurrency   → Data-race safety by default        ║
║  🤖 Foundation Models       → On-device LLM access               ║
║  📱 SwiftUI 6.0             → New modifiers and @Observable      ║
║  🎨 UIKit Updates           → Glass effects and new APIs         ║
║  🛒 StoreKit 2              → Modern In-App Purchase flow        ║
║  🎙️ App Intents             → Enhanced Siri and Shortcuts        ║
║  💊 HealthKit               → New Medications API                ║
║                                                                   ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## ⚡ Quick Start

### 1. Run the Deprecation Scanner

```bash
# Clone the repository
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide

# Scan your project for deprecated APIs
swift scripts/deprecation-scanner.swift /path/to/your/project
```

### 2. Run Auto-Migration

```bash
# Preview changes (dry run)
./scripts/auto-migrate.sh /path/to/your/project --dry-run

# Apply automatic fixes
./scripts/auto-migrate.sh /path/to/your/project
```

### 3. Follow the Checklist

Open [docs/checklist/complete-guide.md](docs/checklist/complete-guide.md) and work through each section systematically.

---

## ✨ What's New in iOS 26

### 🧊 Liquid Glass Design

The most significant visual change since iOS 7.

```swift
// ❌ iOS 25 - Material backgrounds
.background(.ultraThinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)

// ✅ iOS 26 - Liquid Glass
.glassEffect(.subtle)
.glassEffect()
.glassEffect(.prominent)
```

<details>
<summary><b>See Full Liquid Glass Migration Table</b></summary>

| iOS 25 Material | iOS 26 Liquid Glass |
|-----------------|---------------------|
| `.ultraThinMaterial` | `.glassEffect(.subtle)` |
| `.thinMaterial` | `.glassEffect(.light)` |
| `.regularMaterial` | `.glassEffect()` |
| `.thickMaterial` | `.glassEffect(.prominent)` |
| `.ultraThickMaterial` | `.glassEffect(.opaque)` |

</details>

### ⚡ Swift 6.2 Concurrency

```swift
// ❌ iOS 25 - Completion handlers
func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        DispatchQueue.main.async {
            // Handle result
        }
    }.resume()
}

// ✅ iOS 26 - Async/await with strict concurrency
@MainActor
func fetchUser(id: String) async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}
```

### 🤖 Foundation Models

On-device LLM capabilities for the first time.

```swift
import FoundationModels

// Initialize on-device model
let model = try await LanguageModel.default

// Generate text
let response = try await model.generate(
    prompt: "Summarize this email: \(emailContent)",
    maxTokens: 500
)

// Stream responses
for try await chunk in model.stream(prompt: userQuery) {
    print(chunk.text, terminator: "")
}
```

### 📱 SwiftUI Updates

```swift
// ❌ iOS 25 - ObservableObject pattern
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
}

// ✅ iOS 26 - @Observable macro
@Observable
class ViewModel {
    var items: [Item] = []
}

struct ContentView: View {
    @State var viewModel = ViewModel()
}
```

---

## 🛠️ Migration Tools

### Deprecation Scanner

Scans your entire codebase for deprecated APIs and provides migration guidance.

```bash
swift scripts/deprecation-scanner.swift ./MyApp --report ./report.md

# Output:
# 📁 Files Scanned: 247
# 🔴 Errors (will not compile): 12
# 🟡 Warnings (deprecated): 34
# 🔵 Info (recommendations): 56
```

**Features:**
- ✅ Detects removed APIs (compile errors)
- ✅ Identifies deprecated APIs (warnings)
- ✅ Provides replacement suggestions
- ✅ Generates markdown reports
- ✅ Estimates migration effort

### Auto-Migration Script

Automatically fixes common deprecated patterns.

```bash
./scripts/auto-migrate.sh ./MyApp

# Automatic fixes:
# ✅ NavigationView → NavigationStack
# ✅ @StateObject → @State
# ✅ .navigationBarTitle → .navigationTitle
# ✅ Material backgrounds → Glass effects
# ✅ UIScreen.main → windowScene
```

---

## 📚 Documentation

### Core Guides

| Guide | Description | Status |
|-------|-------------|--------|
| [Swift 6 Migration](docs/swift6/migration.md) | Complete async/await and concurrency guide | ✅ Complete |
| [SwiftUI Changes](docs/swiftui-changes.md) | All SwiftUI updates and deprecations | ✅ Complete |
| [UIKit Changes](docs/uikit-changes.md) | UIKit deprecations and new APIs | ✅ Complete |
| [Liquid Glass Implementation](docs/liquid-glass/implementation.md) | Full Liquid Glass implementation guide | ✅ Complete |
| [Liquid Glass Best Practices](docs/liquid-glass/best-practices.md) | Design patterns and performance tips | ✅ Complete |

### Framework Guides

| Framework | Guide | Key Changes |
|-----------|-------|-------------|
| App Intents | [Migration Guide](docs/frameworks/app-intents.md) | SiriKit → App Intents |
| StoreKit | [Migration Guide](docs/frameworks/storekit.md) | StoreKit 1 → StoreKit 2 |
| HealthKit | [Migration Guide](docs/frameworks/healthkit.md) | New Medications API |
| Core ML | [Migration Guide](docs/frameworks/foundation-models.md) | Foundation Models |

### Planning Resources

| Resource | Description |
|----------|-------------|
| [Complete Checklist](docs/checklist/complete-guide.md) | Comprehensive migration checklist |
| [Timeline Recommendations](docs/timeline-recommendations.md) | Week-by-week migration plan |
| [Testing Guide](docs/testing.md) | Testing strategies and best practices |

---

## 🔥 Breaking Changes Summary

### ⛔ Removed (Will Not Compile)

```swift
// These will cause compile errors in iOS 26:

UITableView                    → UICollectionView with list layout
UIScreen.main                  → view.window?.windowScene?.screen
NavigationView                 → NavigationStack / NavigationSplitView
UINavigationBar.appearance()   → Per-instance UINavigationBarAppearance
UIWebView                      → WKWebView
UIAlertView                    → UIAlertController
.navigationBarTitle()          → .navigationTitle()
```

### ⚠️ Deprecated (Warnings)

```swift
// These produce warnings - migrate before iOS 27:

@StateObject                   → @State with @Observable
@ObservedObject                → Direct observation
@EnvironmentObject             → @Environment(Type.self)
@Published                     → @Observable properties
CADisplayLink                  → UIUpdateLink
UIView.animate(withDuration:)  → UIView.animate(springDuration:)
.sheet(isPresented:)           → .presentation(isPresented:style:)
```

---

## 💻 Code Examples

### Before/After: Complete ViewModel

```swift
// ❌ iOS 25
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func loadProducts() {
        isLoading = true
        ProductService.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let products):
                    self?.products = products
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.products) { product in
                ProductRow(product: product)
            }
            .navigationBarTitle("Products")
        }
        .onAppear { viewModel.loadProducts() }
    }
}

// ✅ iOS 26
@Observable
@MainActor
class ProductListViewModel {
    var products: [Product] = []
    var isLoading = false
    var error: Error?
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            products = try await ProductService.shared.fetchProducts()
        } catch {
            self.error = error
        }
    }
}

struct ProductListView: View {
    @State private var viewModel = ProductListViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.products) { product in
                ProductRow(product: product)
                    .glassEffect(.subtle)
            }
            .navigationTitle("Products")
        }
        .task { await viewModel.loadProducts() }
    }
}
```

### Before/After: Network Layer

```swift
// ❌ iOS 25
class NetworkManager {
    func fetch<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        URLSession.shared.dataTask(with: endpoint.request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}

// ✅ iOS 26
actor NetworkManager {
    func fetch<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: endpoint.request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

## 📊 Migration Timeline

```
┌─────────────────────────────────────────────────────────────────┐
│                 RECOMMENDED MIGRATION TIMELINE                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Week 1-2:   🔍 Preparation                                     │
│              • Run deprecation scanner                          │
│              • Update dependencies                              │
│              • Set up iOS 26 environment                        │
│                                                                  │
│  Week 3-4:   ⚡ Swift 6 Migration                                │
│              • Fix concurrency warnings                         │
│              • Add Sendable conformances                        │
│              • Convert to async/await                           │
│                                                                  │
│  Week 5-6:   🧊 UI Migration                                    │
│              • Adopt Liquid Glass                               │
│              • Update navigation                                │
│              • Migrate to @Observable                           │
│                                                                  │
│  Week 7-8:   🔧 Framework Updates                               │
│              • StoreKit 2 migration                             │
│              • App Intents adoption                             │
│              • Other frameworks                                 │
│                                                                  │
│  Week 9-10:  🧪 Testing & Release                               │
│              • Comprehensive testing                            │
│              • Performance optimization                         │
│              • App Store submission                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Quick Checklist

```markdown
## Pre-Migration
- [ ] Run deprecation scanner
- [ ] Update all dependencies
- [ ] Create migration branch
- [ ] Set up iOS 26 simulator

## Swift 6 Migration
- [ ] Enable strict concurrency checking
- [ ] Fix all Sendable warnings
- [ ] Add @MainActor to ViewModels
- [ ] Convert completion handlers to async

## UI Migration
- [ ] Replace NavigationView with NavigationStack
- [ ] Migrate to @Observable
- [ ] Update to @Environment injection
- [ ] Apply Liquid Glass effects

## Testing
- [ ] Run all unit tests
- [ ] Run UI tests on iOS 26 simulator
- [ ] Test on physical device
- [ ] Performance benchmarking

## Release
- [ ] Update screenshots
- [ ] Update App Store description
- [ ] TestFlight beta
- [ ] Submit for review
```

---

## 🤝 Contributing

Contributions are welcome! This guide is maintained by the community for the community.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-tip`)
3. Commit your changes (`git commit -m 'Add amazing migration tip'`)
4. Push to the branch (`git push origin feature/amazing-tip`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Star History

<a href="https://star-history.com/#muhittincamdali/iOS26-Migration-Guide&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
 </picture>
</a>

---

<div align="center">

**Found this guide helpful? Give it a ⭐ to help others find it!**

<br/>

Made with ❤️ by [Muhittin Camdali](https://github.com/muhittincamdali)

[⬆ Back to top](#-ios-26-migration-guide)

</div>
