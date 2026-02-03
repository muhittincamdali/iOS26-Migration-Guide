# Common Issues and Solutions for iOS 26 Migration

This directory contains practical solutions for the most frequently encountered issues during iOS 26 migration. Each section provides working code examples and detailed explanations.

## Table of Contents

1. [Liquid Glass Issues](#liquid-glass-issues)
2. [Navigation & Tab Bar Problems](#navigation--tab-bar-problems)
3. [SwiftUI Migration Issues](#swiftui-migration-issues)
4. [Swift 6 Concurrency Errors](#swift-6-concurrency-errors)
5. [UIKit Deprecations](#uikit-deprecations)
6. [Performance Problems](#performance-problems)
7. [Testing Failures](#testing-failures)

---

## Liquid Glass Issues

### Issue #1: Translucent Background Not Rendering

**Symptom:** Views appear opaque instead of showing the characteristic liquid glass effect.

**Cause:** Missing material configuration or incorrect view hierarchy.

**Before (Broken):**
```swift
struct BrokenGlassView: View {
    var body: some View {
        VStack {
            Text("This won't have glass effect")
                .padding()
        }
        .background(.thinMaterial) // Wrong approach in iOS 26
    }
}
```

**After (Fixed):**
```swift
struct FixedGlassView: View {
    var body: some View {
        VStack {
            Text("Proper liquid glass effect")
                .padding()
        }
        .glassEffect()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
```

**Explanation:** iOS 26 requires the explicit `.glassEffect()` modifier combined with material backgrounds. The system composites these layers to create the proper liquid glass appearance.

---

### Issue #2: Glass Effect Performance on Older Devices

**Symptom:** Frame drops and stuttering when scrolling views with liquid glass.

**Cause:** Complex blur calculations without proper optimization.

**Solution - Adaptive Glass Quality:**
```swift
struct AdaptiveGlassCard: View {
    @Environment(\.displayScale) private var displayScale
    
    private var glassIntensity: Double {
        // Reduce intensity on lower-end devices
        if ProcessInfo.processInfo.physicalMemory < 4_000_000_000 {
            return 0.6
        }
        return 1.0
    }
    
    private var useReducedTransparency: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    var body: some View {
        contentView
            .background {
                if useReducedTransparency {
                    Color(.systemBackground)
                        .opacity(0.95)
                } else {
                    GlassBackgroundView(intensity: glassIntensity)
                }
            }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adaptive Card")
                .font(.headline)
            Text("Automatically adjusts glass quality based on device capabilities")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct GlassBackgroundView: View {
    let intensity: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .opacity(intensity)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            }
    }
}
```

---

### Issue #3: Nested Glass Effects Creating Visual Artifacts

**Symptom:** Overlapping glass elements show dark bands or incorrect blur levels.

**Cause:** Multiple material layers stacking incorrectly.

**Before (Broken):**
```swift
struct BrokenNestedGlass: View {
    var body: some View {
        ZStack {
            // Outer glass
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .frame(width: 300, height: 200)
            
            // Inner glass - creates artifacts
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .frame(width: 200, height: 100)
        }
    }
}
```

**After (Fixed):**
```swift
struct FixedNestedGlass: View {
    var body: some View {
        ZStack {
            // Single glass layer
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .frame(width: 300, height: 200)
            
            // Inner element uses opacity, not additional material
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                }
                .frame(width: 200, height: 100)
        }
    }
}
```

**Best Practice:** Use a single material layer as the base, then build inner elements using opacity and borders rather than additional materials.

---

### Issue #4: Glass Effect Disappears in Dark Mode

**Symptom:** Liquid glass looks perfect in light mode but is barely visible or too dark in dark mode.

**Solution - Adaptive Glass Styling:**
```swift
struct AdaptiveDarkModeGlass: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var glassOpacity: Double {
        colorScheme == .dark ? 0.8 : 0.7
    }
    
    private var borderOpacity: Double {
        colorScheme == .dark ? 0.25 : 0.15
    }
    
    private var overlayGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(colorScheme == .dark ? 0.15 : 0.3),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack {
            Text("Adaptive Glass Card")
                .font(.headline)
            Text("Works beautifully in both light and dark mode")
                .font(.caption)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(glassOpacity)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(overlayGradient)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(borderOpacity), lineWidth: 1)
                }
        }
    }
}
```

---

## Navigation & Tab Bar Problems

### Issue #5: Tab Bar Icons Misaligned After Migration

**Symptom:** Custom tab bar icons appear shifted or sized incorrectly.

**Cause:** iOS 26 changed the default tab bar item insets and sizing.

**Before (Broken):**
```swift
class OldTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Old approach - doesn't work correctly in iOS 26
        tabBar.itemPositioning = .centered
        tabBar.itemWidth = 60
        tabBar.itemSpacing = 20
    }
}
```

**After (Fixed):**
```swift
class ModernTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // iOS 26 uses glass effect by default
        if #available(iOS 26, *) {
            appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        }
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .secondaryLabel
        itemAppearance.selected.iconColor = .systemBlue
        
        // Apply consistent sizing
        itemAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        itemAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
```

---

### Issue #6: Navigation Title Truncated with Large Titles

**Symptom:** Long navigation titles get cut off incorrectly in iOS 26.

**Solution:**
```swift
class FixedNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationAppearance()
    }
    
    private func configureNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Configure large title
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        // Configure standard title with proper sizing
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        // Enable automatic title adjustment
        navigationBar.prefersLargeTitles = true
    }
}

// SwiftUI equivalent
struct FixedNavigationView: View {
    var body: some View {
        NavigationStack {
            ContentListView()
                .navigationTitle("My Very Long Navigation Title")
                .navigationBarTitleDisplayMode(.large)
                .toolbarTitleDisplayMode(.automatic)
        }
    }
}
```

---

### Issue #7: Back Button Gesture Conflicts

**Symptom:** Custom gesture recognizers interfere with the new edge swipe behavior.

**Solution:**
```swift
class GestureAwareViewController: UIViewController, UIGestureRecognizerDelegate {
    private var customPanGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }
    
    private func setupGestures() {
        customPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        customPanGesture.delegate = self
        view.addGestureRecognizer(customPanGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Handle custom pan logic
        print("Pan translation: \(translation)")
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == customPanGesture else { return true }
        
        let velocity = customPanGesture.velocity(in: view)
        let location = customPanGesture.location(in: view)
        
        // Allow system back gesture on left edge
        let edgeThreshold: CGFloat = 30
        if location.x < edgeThreshold && velocity.x > 0 {
            return false // Let system handle the back gesture
        }
        
        return true
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow simultaneous recognition for smoother interactions
        return true
    }
}
```

---

## SwiftUI Migration Issues

### Issue #8: Observable Macro Migration Errors

**Symptom:** Compiler errors when migrating from `ObservableObject` to `@Observable`.

**Before (Old Pattern):**
```swift
// iOS 16 pattern
class UserSettings: ObservableObject {
    @Published var username: String = ""
    @Published var notificationsEnabled: Bool = true
    @Published var theme: AppTheme = .system
    
    func updateUsername(_ newName: String) {
        username = newName
    }
}

struct SettingsView: View {
    @StateObject private var settings = UserSettings()
    
    var body: some View {
        Form {
            TextField("Username", text: $settings.username)
            Toggle("Notifications", isOn: $settings.notificationsEnabled)
        }
    }
}
```

**After (iOS 26 Pattern):**
```swift
// iOS 26 pattern with @Observable
@Observable
class UserSettings {
    var username: String = ""
    var notificationsEnabled: Bool = true
    var theme: AppTheme = .system
    
    // Computed properties work automatically
    var isConfigured: Bool {
        !username.isEmpty
    }
    
    func updateUsername(_ newName: String) {
        username = newName
    }
}

struct SettingsView: View {
    @State private var settings = UserSettings()
    
    var body: some View {
        Form {
            TextField("Username", text: $settings.username)
            Toggle("Notifications", isOn: $settings.notificationsEnabled)
            
            if settings.isConfigured {
                Text("Welcome, \(settings.username)!")
            }
        }
    }
}

// For shared instances across the app
struct ContentView: View {
    var body: some View {
        SettingsView()
            .environment(UserSettings())
    }
}
```

---

### Issue #9: Environment Injection Failures

**Symptom:** `@Environment` values return nil or default values unexpectedly.

**Solution - Proper Environment Setup:**
```swift
// Define custom environment key
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

@Observable
class ThemeManager {
    var primaryColor: Color = .blue
    var secondaryColor: Color = .gray
    var cornerRadius: CGFloat = 12
    
    func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .light:
            primaryColor = .blue
            secondaryColor = .gray
        case .dark:
            primaryColor = .indigo
            secondaryColor = .gray.opacity(0.8)
        case .system:
            primaryColor = .accentColor
            secondaryColor = .secondary
        }
    }
}

// Correct usage
struct AppRoot: View {
    @State private var themeManager = ThemeManager()
    
    var body: some View {
        ContentView()
            .environment(themeManager) // iOS 26 syntax
            .environment(\.themeManager, themeManager) // Also set via keypath
    }
}

struct ThemedButton: View {
    @Environment(ThemeManager.self) private var theme
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(.white)
                .padding()
                .background(theme.primaryColor, in: RoundedRectangle(cornerRadius: theme.cornerRadius))
        }
    }
}
```

---

### Issue #10: Animation Timing Changes

**Symptom:** Animations feel different or don't match the expected iOS 26 spring physics.

**Solution - Updated Animation APIs:**
```swift
struct ModernAnimationsView: View {
    @State private var isExpanded = false
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // iOS 26 spring animations
            ExpandableCard(isExpanded: $isExpanded)
                .animation(.spring(duration: 0.5, bounce: 0.3), value: isExpanded)
            
            // Custom spring with damping
            DraggableCard(offset: $cardOffset)
                .animation(
                    .interpolatingSpring(
                        mass: 1.0,
                        stiffness: 200,
                        damping: 20,
                        initialVelocity: 0
                    ),
                    value: cardOffset
                )
            
            // Smooth transitions
            TransitionDemo()
        }
    }
}

struct ExpandableCard: View {
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Expandable Content")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            
            if isExpanded {
                Text("This is the expanded content that appears with a smooth spring animation.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

struct DraggableCard: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.thinMaterial)
            .frame(width: 200, height: 100)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { _ in
                        offset = 0
                    }
            )
    }
}
```

---

## Swift 6 Concurrency Errors

### Issue #11: Sendable Conformance Errors

**Symptom:** Compiler errors about types not conforming to `Sendable`.

**Before (Broken):**
```swift
// This class causes Sendable warnings
class DataManager {
    var cachedData: [String: Any] = [:]
    
    func fetchData() async throws -> Data {
        // Network call
        let url = URL(string: "https://api.example.com/data")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

struct ContentView: View {
    let manager = DataManager()
    
    var body: some View {
        Button("Fetch") {
            Task {
                // Warning: Capture of non-sendable type
                let data = try? await manager.fetchData()
            }
        }
    }
}
```

**After (Fixed):**
```swift
// Option 1: Actor-based solution
actor DataManager {
    private var cachedData: [String: Data] = [:]
    
    func fetchData(for key: String) async throws -> Data {
        if let cached = cachedData[key] {
            return cached
        }
        
        let url = URL(string: "https://api.example.com/\(key)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        cachedData[key] = data
        return data
    }
    
    func clearCache() {
        cachedData.removeAll()
    }
}

// Option 2: Sendable struct with immutable data
struct DataFetcher: Sendable {
    let baseURL: URL
    
    init(baseURL: URL = URL(string: "https://api.example.com")!) {
        self.baseURL = baseURL
    }
    
    func fetchData(endpoint: String) async throws -> Data {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

// Option 3: MainActor-isolated class for UI state
@MainActor
class ViewStateManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var data: Data?
    
    private let fetcher = DataFetcher()
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            data = try await fetcher.fetchData(endpoint: "items")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

---

### Issue #12: Data Race Warnings

**Symptom:** Runtime warnings or crashes related to simultaneous access.

**Solution - Proper Isolation:**
```swift
// Unsafe pattern - data race possible
class UnsafeCounter {
    var count = 0
    
    func increment() {
        count += 1 // Data race when called from multiple threads
    }
}

// Safe pattern using actor
actor SafeCounter {
    private(set) var count = 0
    
    func increment() {
        count += 1
    }
    
    func reset() {
        count = 0
    }
}

// Safe pattern using locks (when actor overhead is too much)
final class ThreadSafeCounter: @unchecked Sendable {
    private var _count = 0
    private let lock = NSLock()
    
    var count: Int {
        lock.withLock { _count }
    }
    
    func increment() {
        lock.withLock { _count += 1 }
    }
    
    func reset() {
        lock.withLock { _count = 0 }
    }
}

// Usage in async context
struct CounterDemo {
    func demonstrateSafeAccess() async {
        let counter = SafeCounter()
        
        // Parallel increments - all safe
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1000 {
                group.addTask {
                    await counter.increment()
                }
            }
        }
        
        let finalCount = await counter.count
        print("Final count: \(finalCount)") // Always 1000
    }
}
```

---

### Issue #13: Async Sequence Migration

**Symptom:** Old completion handler patterns don't work with new async APIs.

**Before (Old Pattern):**
```swift
class LegacyNetworkManager {
    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = URL(string: "https://api.example.com/users")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
```

**After (Modern Async Pattern):**
```swift
actor ModernNetworkManager {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchUsers() async throws -> [User] {
        let url = URL(string: "https://api.example.com/users")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try decoder.decode([User].self, from: data)
    }
    
    // Stream updates using AsyncSequence
    func userUpdates() -> AsyncStream<User> {
        AsyncStream { continuation in
            let task = Task {
                // Simulated real-time updates
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(5))
                    
                    if let users = try? await fetchUsers(),
                       let randomUser = users.randomElement() {
                        continuation.yield(randomUser)
                    }
                }
                continuation.finish()
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

// Bridge for legacy code that needs completion handlers
extension ModernNetworkManager {
    nonisolated func fetchUsersLegacy(completion: @escaping (Result<[User], Error>) -> Void) {
        Task {
            do {
                let users = try await self.fetchUsers()
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
```

---

## UIKit Deprecations

### Issue #14: UIAlertController Style Changes

**Symptom:** Alert controllers look different or behave unexpectedly.

**Solution:**
```swift
extension UIViewController {
    func showModernAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = []
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if actions.isEmpty {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            actions.forEach { alert.addAction($0) }
        }
        
        // iOS 26 specific configurations
        if #available(iOS 26, *) {
            // Enable the new glass background effect
            alert.view.backgroundColor = .clear
            
            // Configure for the new presentation style
            alert.modalPresentationStyle = .pageSheet
            if let sheet = alert.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
            }
        }
        
        present(alert, animated: true)
    }
    
    func showModernActionSheet(
        title: String?,
        message: String?,
        actions: [UIAlertAction],
        sourceView: UIView? = nil
    ) {
        let actionSheet = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        
        actions.forEach { actionSheet.addAction($0) }
        
        // Required for iPad
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = sourceView ?? view
            popover.sourceRect = sourceView?.bounds ?? CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(actionSheet, animated: true)
    }
}
```

---

### Issue #15: Collection View Layout Deprecations

**Symptom:** UICollectionViewFlowLayout behaves differently in iOS 26.

**Solution - Migrate to Compositional Layout:**
```swift
class ModernCollectionViewController: UICollectionViewController {
    
    enum Section: Int, CaseIterable {
        case featured
        case regular
        case compact
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        applyInitialSnapshot()
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            return self?.createLayoutSection(for: section, environment: environment)
        }
    }
    
    private func createLayoutSection(
        for section: Section,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        switch section {
        case .featured:
            return createFeaturedSection()
        case .regular:
            return createRegularSection(environment: environment)
        case .compact:
            return createCompactSection()
        }
    }
    
    private func createFeaturedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }
    
    private func createRegularSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let columns = environment.container.effectiveContentSize.width > 600 ? 3 : 2
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        return section
    }
    
    private func createCompactSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, item in
            var config = UIListContentConfiguration.cell()
            config.text = item.title
            config.secondaryText = item.subtitle
            cell.contentConfiguration = config
            
            // iOS 26 glass background
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.cornerRadius = 12
            backgroundConfig.backgroundColor = .secondarySystemGroupedBackground
            cell.backgroundConfiguration = backgroundConfig
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        // Add items to sections
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

struct Item: Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
}
```

---

## Performance Problems

### Issue #16: Main Thread Blocking

**Symptom:** UI freezes during data processing.

**Solution - Proper Background Processing:**
```swift
actor DataProcessor {
    func processLargeDataset(_ items: [RawItem]) async -> [ProcessedItem] {
        // Process in chunks to allow cancellation checks
        var results: [ProcessedItem] = []
        results.reserveCapacity(items.count)
        
        let chunkSize = 100
        for chunk in items.chunked(into: chunkSize) {
            // Check for cancellation
            try? Task.checkCancellation()
            
            // Process chunk
            let processed = chunk.map { ProcessedItem(from: $0) }
            results.append(contentsOf: processed)
            
            // Yield to allow other work
            await Task.yield()
        }
        
        return results
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// View with proper async handling
struct DataListView: View {
    @State private var items: [ProcessedItem] = []
    @State private var isLoading = false
    @State private var loadTask: Task<Void, Never>?
    
    private let processor = DataProcessor()
    
    var body: some View {
        List(items) { item in
            ItemRow(item: item)
        }
        .overlay {
            if isLoading {
                ProgressView("Processing...")
            }
        }
        .task {
            await loadData()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }
    
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        loadTask = Task {
            let rawItems = await fetchRawItems()
            items = await processor.processLargeDataset(rawItems)
        }
        
        await loadTask?.value
    }
    
    private func fetchRawItems() async -> [RawItem] {
        // Fetch implementation
        []
    }
}
```

---

### Issue #17: Memory Leaks with Closures

**Symptom:** Memory usage grows over time, views not deallocating.

**Solution - Proper Capture Lists:**
```swift
class SubscriptionManager {
    private var subscriptions: [AnyCancellable] = []
    private var tasks: [Task<Void, Never>] = []
    
    // Wrong - creates retain cycle
    func setupBadSubscription() {
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.handleActivation() // Strong reference to self
            }
            .store(in: &subscriptions)
    }
    
    // Correct - weak capture
    func setupGoodSubscription() {
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleActivation()
            }
            .store(in: &subscriptions)
    }
    
    // Correct for async tasks
    func startBackgroundTask() {
        let task = Task { [weak self] in
            while !Task.isCancelled {
                await self?.performPeriodicWork()
                try? await Task.sleep(for: .seconds(60))
            }
        }
        tasks.append(task)
    }
    
    func cleanup() {
        subscriptions.removeAll()
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    private func handleActivation() {
        print("App became active")
    }
    
    private func performPeriodicWork() async {
        print("Performing periodic work")
    }
    
    deinit {
        cleanup()
        print("SubscriptionManager deallocated")
    }
}
```

---

## Testing Failures

### Issue #18: Async Test Timeouts

**Symptom:** Tests timeout when testing async code.

**Solution:**
```swift
import XCTest
@testable import MyApp

final class AsyncNetworkTests: XCTestCase {
    var sut: NetworkService!
    
    override func setUp() {
        super.setUp()
        sut = NetworkService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // Proper async test
    func testFetchUserReturnsValidData() async throws {
        // Given
        let expectedUserId = "123"
        
        // When
        let user = try await sut.fetchUser(id: expectedUserId)
        
        // Then
        XCTAssertEqual(user.id, expectedUserId)
        XCTAssertFalse(user.name.isEmpty)
    }
    
    // Test with custom timeout
    func testSlowOperationCompletes() async throws {
        // Use withTimeout for operations that might hang
        try await withTimeout(seconds: 10) {
            let result = try await sut.performSlowOperation()
            XCTAssertNotNil(result)
        }
    }
    
    // Test cancellation behavior
    func testCancellationStopsOperation() async {
        let task = Task {
            try await sut.performLongRunningTask()
        }
        
        // Cancel after brief delay
        try? await Task.sleep(for: .milliseconds(100))
        task.cancel()
        
        // Verify task was cancelled
        let result = await task.result
        switch result {
        case .success:
            XCTFail("Task should have been cancelled")
        case .failure(let error):
            XCTAssertTrue(error is CancellationError)
        }
    }
}

// Helper for timeout
func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimeoutError()
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

struct TimeoutError: Error {}
```

---

### Issue #19: UI Testing Flakiness

**Symptom:** UI tests pass locally but fail in CI, or fail intermittently.

**Solution:**
```swift
import XCTest

final class RobustUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launchEnvironment = [
            "ANIMATIONS_DISABLED": "1",
            "NETWORK_STUB": "1"
        ]
        app.launch()
    }
    
    func testLoginFlow() {
        // Wait for initial load
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        
        // Enter credentials with retry
        let emailField = app.textFields["emailField"]
        tapWithRetry(emailField)
        emailField.typeText("test@example.com")
        
        let passwordField = app.secureTextFields["passwordField"]
        tapWithRetry(passwordField)
        passwordField.typeText("password123")
        
        // Submit and wait for result
        loginButton.tap()
        
        // Wait for navigation with explicit condition
        let homeScreen = app.otherElements["homeScreen"]
        let appeared = homeScreen.waitForExistence(timeout: 15)
        XCTAssertTrue(appeared, "Home screen should appear after login")
    }
    
    // Helper for flaky taps
    private func tapWithRetry(_ element: XCUIElement, maxAttempts: Int = 3) {
        for attempt in 1...maxAttempts {
            if element.exists && element.isHittable {
                element.tap()
                return
            }
            
            if attempt < maxAttempts {
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        XCTFail("Could not tap element after \(maxAttempts) attempts")
    }
}

// Extension for better waiting
extension XCUIElement {
    func waitForHittable(timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "exists == true AND isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
```

---

## Quick Reference Table

| Issue | Symptom | Quick Fix |
|-------|---------|-----------|
| Glass not rendering | Opaque views | Add `.glassEffect()` modifier |
| Glass performance | Frame drops | Use adaptive quality based on device |
| Nested glass artifacts | Dark bands | Single material layer + opacity overlays |
| Dark mode glass | Invisible glass | Adjust opacity per color scheme |
| Tab bar icons | Misaligned | Use `UITabBarAppearance` |
| Nav title truncated | Cut off text | Configure `UINavigationBarAppearance` |
| Gesture conflicts | Back swipe broken | Implement gesture delegate |
| Observable migration | Compiler errors | Replace `@StateObject` with `@State` |
| Environment nil | Missing values | Use both `environment()` syntaxes |
| Animation timing | Wrong feel | Use new `spring(duration:bounce:)` |
| Sendable errors | Compiler warnings | Use actors or `@MainActor` |
| Data races | Crashes | Actor isolation or locks |
| Completion handlers | Old API style | Convert to async/await |
| Alert changes | Wrong appearance | Configure for iOS 26 glass style |
| Collection layout | Deprecated warnings | Migrate to Compositional Layout |
| Main thread blocking | UI freezes | Process on background with `Task` |
| Memory leaks | Growing memory | Use `[weak self]` in closures |
| Test timeouts | Tests fail | Use proper async test patterns |
| UI test flakiness | Intermittent fails | Add waits and retry logic |

---

## Additional Resources

- [Apple iOS 26 Release Notes](https://developer.apple.com/documentation/ios-ipados-release-notes)
- [Swift 6 Migration Guide](https://www.swift.org/migration/documentation/migrationguide/)
- [Human Interface Guidelines - iOS 26](https://developer.apple.com/design/human-interface-guidelines/)
- [WWDC26 Session Videos](https://developer.apple.com/videos/)

---

## Contributing

Found a new issue? Please submit a PR with:
1. Clear symptom description
2. Minimal reproduction code
3. Working solution
4. Explanation of why it works

All contributions should follow the existing format for consistency.
