# SwiftUI New APIs in iOS 26

Complete reference for new SwiftUI APIs introduced in iOS 26.

## Table of Contents

1. [Glass Effect Modifiers](#glass-effect-modifiers)
2. [Enhanced Navigation](#enhanced-navigation)
3. [New View Types](#new-view-types)
4. [Improved Animations](#improved-animations)
5. [Layout System Updates](#layout-system-updates)
6. [Data Flow Enhancements](#data-flow-enhancements)
7. [Gesture System](#gesture-system)
8. [Accessibility APIs](#accessibility-apis)
9. [Performance APIs](#performance-apis)
10. [Platform Integration](#platform-integration)

---

## Glass Effect Modifiers

### Basic Glass Effect

```swift
// Standard glass effect
View()
    .glassEffect()

// Glass with style
View()
    .glassEffect(.prominent)
    .glassEffect(.subtle)
    .glassEffect(.regular)

// Glass with custom shape
View()
    .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    .glassEffect(in: Capsule())
    .glassEffect(in: Circle())
```

### Tinted Glass

```swift
// Color tinted glass
View()
    .glassEffect(tint: .blue)
    .glassEffect(tint: .purple.opacity(0.3))

// Combined style and tint
View()
    .glassEffect(.prominent, tint: .orange.opacity(0.2))
```

### Full Glass Modifier Signature

```swift
extension View {
    func glassEffect(
        _ style: GlassStyle = .regular,
        in shape: some Shape = Rectangle(),
        tint: Color = .clear
    ) -> some View
}

enum GlassStyle {
    case subtle      // Minimal blur, high transparency
    case regular     // Standard appearance
    case prominent   // Increased blur, lower transparency
}
```

### Glass Background Modifier

```swift
// New background modifier variant
View()
    .glassBackground()
    .glassBackground(.prominent)
    .glassBackground(cornerRadius: 20)

// With safe area handling
View()
    .glassBackground(ignoresSafeArea: .all)
```

---

## Enhanced Navigation

### NavigationStack Improvements

```swift
// New path binding options
struct NavigationExample: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ContentView()
                .navigationDestination(for: Route.self) { route in
                    route.destination
                }
        }
        // New: Restore state automatically
        .navigationPathStore(.automatic)
    }
}

enum Route: Hashable {
    case detail(Item)
    case settings
    case profile(User)
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .detail(let item):
            ItemDetailView(item: item)
        case .settings:
            SettingsView()
        case .profile(let user):
            ProfileView(user: user)
        }
    }
}
```

### Navigation Transitions

```swift
// Custom navigation transitions
struct CustomTransitionView: View {
    var body: some View {
        NavigationStack {
            ContentView()
                .navigationTransition(.slide)
                .navigationTransition(.zoom)
                .navigationTransition(.fade)
                .navigationTransition(.custom(CustomTransition()))
        }
    }
}

// Define custom transition
struct CustomTransition: NavigationTransition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity(phase.isIdentity ? 1 : 0.5)
            .scaleEffect(phase.isIdentity ? 1 : 0.9)
    }
}
```

### NavigationSplitView Enhancements

```swift
struct SplitViewExample: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } content: {
            // Content column
            ContentListView(selection: $selectedItem)
                .navigationSplitViewColumnWidth(ideal: 350)
        } detail: {
            // Detail view
            if let item = selectedItem {
                DetailView(item: item)
            } else {
                ContentUnavailableView(
                    "Select an Item",
                    systemImage: "doc.text"
                )
            }
        }
        // New: Adaptive behavior control
        .navigationSplitViewStyle(.adaptive)
        // New: Column collapse behavior
        .navigationSplitViewCollapse(.automatic)
    }
}
```

### Tab Navigation Updates

```swift
struct TabViewExample: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                // New: Badge with count
                .badge(5)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(2)
                // New: Badge with indicator
                .badge(.indicator)
        }
        // New: Tab bar style
        .tabViewStyle(.glass)
        // New: Tab bar visibility
        .tabBarVisibility(.automatic)
    }
}
```

---

## New View Types

### ContentUnavailableView Enhancements

```swift
// Basic usage
ContentUnavailableView(
    "No Results",
    systemImage: "magnifyingglass",
    description: Text("Try adjusting your search")
)

// With action
ContentUnavailableView {
    Label("No Connection", systemImage: "wifi.slash")
} description: {
    Text("Check your internet connection")
} actions: {
    Button("Retry") {
        // Retry logic
    }
    .buttonStyle(.borderedProminent)
}

// Search variant
ContentUnavailableView.search

// Search with query
ContentUnavailableView.search(text: searchQuery)
```

### InspectorView

```swift
struct InspectorExample: View {
    @State private var showInspector = false
    @State private var selectedItem: Item?
    
    var body: some View {
        ContentView()
            .inspector(isPresented: $showInspector) {
                if let item = selectedItem {
                    ItemInspector(item: item)
                        .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showInspector.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                }
            }
    }
}
```

### DisclosureGroup Updates

```swift
struct DisclosureExample: View {
    @State private var expandedSections: Set<String> = ["general"]
    
    var body: some View {
        List {
            // Managed expansion state
            DisclosureGroup("General", isExpanded: binding(for: "general")) {
                SettingRow(title: "Language")
                SettingRow(title: "Region")
            }
            
            DisclosureGroup("Privacy", isExpanded: binding(for: "privacy")) {
                SettingRow(title: "Location")
                SettingRow(title: "Camera")
            }
            
            // New: Custom disclosure style
            DisclosureGroup("Advanced") {
                AdvancedSettings()
            }
            .disclosureGroupStyle(.glass)
        }
    }
    
    func binding(for section: String) -> Binding<Bool> {
        Binding(
            get: { expandedSections.contains(section) },
            set: { isExpanded in
                if isExpanded {
                    expandedSections.insert(section)
                } else {
                    expandedSections.remove(section)
                }
            }
        )
    }
}
```

### GroupBox Styles

```swift
struct GroupBoxExample: View {
    var body: some View {
        VStack(spacing: 20) {
            // Standard glass style
            GroupBox("Account") {
                AccountSettings()
            }
            .groupBoxStyle(.glass)
            
            // Tinted glass
            GroupBox("Notifications") {
                NotificationSettings()
            }
            .groupBoxStyle(.glassTinted(.blue))
            
            // Custom style
            GroupBox {
                CustomContent()
            } label: {
                Label("Premium", systemImage: "star.fill")
            }
            .groupBoxStyle(PremiumGroupBoxStyle())
        }
    }
}

struct PremiumGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)
            
            configuration.content
        }
        .padding()
        .glassEffect(
            .prominent,
            tint: .yellow.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}
```

---

## Improved Animations

### New Animation Types

```swift
// Spring animations with new parameters
withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
    // Changes
}

// Smooth spring (no bounce)
withAnimation(.smooth(duration: 0.4)) {
    // Changes
}

// Snappy spring (quick settle)
withAnimation(.snappy(duration: 0.3)) {
    // Changes
}

// Bouncy spring
withAnimation(.bouncy(duration: 0.6)) {
    // Changes
}
```

### Phase Animator

```swift
struct PhaseAnimatorExample: View {
    var body: some View {
        PhaseAnimator([false, true]) { phase in
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundStyle(phase ? .red : .pink)
                .scaleEffect(phase ? 1.2 : 1.0)
        } animation: { phase in
            phase ? .bouncy(duration: 0.3) : .smooth(duration: 0.5)
        }
    }
}

// Multi-phase animation
struct MultiPhaseAnimator: View {
    enum AnimationPhase: CaseIterable {
        case initial, expand, rotate, settle
    }
    
    var body: some View {
        PhaseAnimator(AnimationPhase.allCases) { phase in
            StarShape()
                .fill(.yellow)
                .frame(width: 100, height: 100)
                .scaleEffect(phase == .expand ? 1.5 : 1.0)
                .rotationEffect(.degrees(phase == .rotate ? 72 : 0))
                .opacity(phase == .initial ? 0.5 : 1.0)
        }
    }
}
```

### Keyframe Animator

```swift
struct KeyframeAnimatorExample: View {
    @State private var animating = false
    
    var body: some View {
        VStack {
            KeyframeAnimator(initialValue: AnimationValues()) { values in
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .scaleEffect(values.scale)
                    .rotationEffect(values.rotation)
                    .offset(y: values.yOffset)
            } keyframes: { _ in
                KeyframeTrack(\.scale) {
                    SpringKeyframe(1.5, duration: 0.3)
                    SpringKeyframe(1.0, duration: 0.2)
                }
                
                KeyframeTrack(\.rotation) {
                    LinearKeyframe(.degrees(0), duration: 0.1)
                    LinearKeyframe(.degrees(360), duration: 0.4)
                }
                
                KeyframeTrack(\.yOffset) {
                    SpringKeyframe(-50, duration: 0.2)
                    SpringKeyframe(0, duration: 0.3)
                }
            }
        }
    }
    
    struct AnimationValues {
        var scale: CGFloat = 1.0
        var rotation: Angle = .zero
        var yOffset: CGFloat = 0
    }
}
```

### Transition Enhancements

```swift
// New built-in transitions
struct TransitionExample: View {
    @State private var isVisible = true
    
    var body: some View {
        VStack {
            if isVisible {
                // Blur transition
                ContentView()
                    .transition(.blurReplace)
                
                // Symbol effect transition
                ContentView()
                    .transition(.symbolEffect)
                
                // Combined with glass
                ContentView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

// Custom matched geometry transitions
struct MatchedTransitionExample: View {
    @Namespace private var namespace
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            if isExpanded {
                ExpandedView()
                    .matchedGeometryEffect(id: "card", in: namespace)
                    .matchedTransitionSource(id: "card", in: namespace)
            } else {
                CompactView()
                    .matchedGeometryEffect(id: "card", in: namespace)
            }
        }
    }
}
```

---

## Layout System Updates

### New Layout Protocol Features

```swift
// Custom layout with caching
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    struct CacheData {
        var rows: [[LayoutSubviews.Element]]
        var totalHeight: CGFloat
    }
    
    func makeCache(subviews: Subviews) -> CacheData {
        // Calculate and cache row assignments
        CacheData(rows: [], totalHeight: 0)
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var rows: [[LayoutSubviews.Element]] = [[]]
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
                rows.append([])
            }
            
            rows[rows.count - 1].append(subview)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        cache.rows = rows
        cache.totalHeight = currentY + lineHeight
        
        return CGSize(width: width, height: cache.totalHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout CacheData
    ) {
        var currentY = bounds.minY
        
        for row in cache.rows {
            var currentX = bounds.minX
            var lineHeight: CGFloat = 0
            
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: currentX, y: currentY),
                    proposal: ProposedViewSize(size)
                )
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            currentY += lineHeight + spacing
        }
    }
}

// Usage
struct FlowLayoutExample: View {
    let tags = ["SwiftUI", "iOS 26", "Liquid Glass", "Animation", "Layout"]
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect(.subtle, in: Capsule())
            }
        }
    }
}
```

### ViewThatFits Improvements

```swift
struct AdaptiveContent: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Preferred: Full horizontal layout
            HStack(spacing: 20) {
                FeatureCard(title: "Feature A", icon: "star")
                FeatureCard(title: "Feature B", icon: "heart")
                FeatureCard(title: "Feature C", icon: "bolt")
            }
            
            // Fallback: Two columns
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                FeatureCard(title: "Feature A", icon: "star")
                FeatureCard(title: "Feature B", icon: "heart")
                FeatureCard(title: "Feature C", icon: "bolt")
            }
            
            // Final fallback: Single column
            VStack(spacing: 12) {
                FeatureCard(title: "Feature A", icon: "star")
                FeatureCard(title: "Feature B", icon: "heart")
                FeatureCard(title: "Feature C", icon: "bolt")
            }
        }
    }
}
```

### Container Relative Sizing

```swift
struct ContainerRelativeExample: View {
    var body: some View {
        HStack(spacing: 16) {
            // New: Container-relative sizing
            Text("Sidebar")
                .containerRelativeFrame(.horizontal) { length, _ in
                    length * 0.3
                }
                .glassEffect()
            
            Text("Main Content")
                .containerRelativeFrame(.horizontal) { length, _ in
                    length * 0.7
                }
                .glassEffect()
        }
    }
}

// With axis specification
struct ScrollContainerExample: View {
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<10) { index in
                    ContentCard(index: index)
                        .containerRelativeFrame(
                            .horizontal,
                            count: 3,
                            span: 1,
                            spacing: 16
                        )
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
    }
}
```

---

## Data Flow Enhancements

### Observable Macro Updates

```swift
@Observable
class AppState {
    var user: User?
    var isAuthenticated: Bool = false
    var preferences: UserPreferences = .default
    
    // New: Computed observable properties
    var displayName: String {
        user?.name ?? "Guest"
    }
    
    // New: Observable with willSet/didSet
    var theme: Theme = .system {
        willSet {
            NotificationCenter.default.post(name: .themeWillChange, object: newValue)
        }
        didSet {
            NotificationCenter.default.post(name: .themeDidChange, object: theme)
        }
    }
}

struct AppStateExample: View {
    @State private var appState = AppState()
    
    var body: some View {
        ContentView()
            .environment(appState)
    }
}
```

### Bindable Enhancements

```swift
struct BindableExample: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            // Direct binding to observable properties
            Toggle("Notifications", isOn: $viewModel.notificationsEnabled)
            
            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(Theme.allCases) { theme in
                    Text(theme.name).tag(theme)
                }
            }
            
            // New: Binding with validation
            TextField("Username", text: $viewModel.username)
                .validated(by: viewModel.usernameValidation)
        }
    }
}

@Observable
class SettingsViewModel {
    var notificationsEnabled = true
    var selectedTheme: Theme = .system
    var username = ""
    
    var usernameValidation: ValidationResult {
        if username.isEmpty {
            return .invalid("Username required")
        } else if username.count < 3 {
            return .invalid("Minimum 3 characters")
        }
        return .valid
    }
}
```

### State Restoration

```swift
struct StateRestorationExample: View {
    @SceneStorage("selectedTab") private var selectedTab = 0
    @SceneStorage("scrollPosition") private var scrollPosition: CGFloat = 0
    
    // New: Complex state restoration
    @SceneStorage("navigationPath") private var navigationData: Data?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPath) {
                ContentView()
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)
        }
    }
    
    var navigationPath: Binding<NavigationPath> {
        Binding(
            get: {
                guard let data = navigationData else { return NavigationPath() }
                return (try? JSONDecoder().decode(NavigationPath.self, from: data)) 
                    ?? NavigationPath()
            },
            set: { path in
                navigationData = try? JSONEncoder().encode(path)
            }
        )
    }
}
```

---

## Gesture System

### New Gesture Types

```swift
// Long press with progress
struct LongPressProgressExample: View {
    @State private var progress: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.blue.opacity(0.3))
            .overlay {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.blue, lineWidth: 4)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 100, height: 100)
            .gesture(
                LongPressGesture(minimumDuration: 2)
                    .updating($progress) { value, state, _ in
                        state = value ? 1 : 0
                    }
            )
    }
    
    @GestureState private var progress: CGFloat = 0
}
```

### Gesture Composition

```swift
struct ComposedGestureExample: View {
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1
    @State private var rotation: Angle = .zero
    
    var body: some View {
        Image(systemName: "photo")
            .font(.system(size: 100))
            .offset(offset)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .gesture(
                // New: Simultaneous gesture composition
                SimultaneousGesture(
                    SimultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            },
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value
                            }
                    ),
                    RotationGesture()
                        .onChanged { value in
                            rotation = value
                        }
                )
            )
    }
}
```

### Gesture Velocity

```swift
struct VelocityGestureExample: View {
    @State private var offset = CGSize.zero
    @State private var velocity = CGSize.zero
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.blue)
            .frame(width: 100, height: 100)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { value in
                        // New: Access velocity
                        velocity = value.velocity
                        
                        // Apply momentum
                        withAnimation(.smooth(duration: 0.5)) {
                            offset.width += velocity.width * 0.1
                            offset.height += velocity.height * 0.1
                        }
                    }
            )
    }
}
```

---

## Accessibility APIs

### AccessibilityFocus Improvements

```swift
struct AccessibilityFocusExample: View {
    @AccessibilityFocusState private var focusedElement: Element?
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .accessibilityFocused($focusedElement, equals: .name)
            
            TextField("Email", text: $email)
                .accessibilityFocused($focusedElement, equals: .email)
            
            Button("Submit") {
                if name.isEmpty {
                    focusedElement = .name
                } else if email.isEmpty {
                    focusedElement = .email
                }
            }
        }
    }
    
    @State private var name = ""
    @State private var email = ""
    
    enum Element: Hashable {
        case name, email
    }
}
```

### Custom Accessibility Actions

```swift
struct CustomAccessibilityActions: View {
    @State private var item: Item
    
    var body: some View {
        ItemCard(item: item)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(item.accessibilityLabel)
            .accessibilityActions {
                // Primary action
                Button("Open") {
                    openItem()
                }
                
                // Secondary actions
                Button("Share") {
                    shareItem()
                }
                
                Button("Delete") {
                    deleteItem()
                }
                
                // New: Adjustable action
                AccessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        item.quantity += 1
                    case .decrement:
                        item.quantity -= 1
                    @unknown default:
                        break
                    }
                }
            }
    }
    
    func openItem() {}
    func shareItem() {}
    func deleteItem() {}
}
```

### Accessibility Representation

```swift
struct AccessibilityRepresentationExample: View {
    var body: some View {
        CustomChart(data: chartData)
            .accessibilityRepresentation {
                // Provide alternative representation for VoiceOver
                List(chartData) { point in
                    Text("\(point.label): \(point.value)")
                }
            }
    }
    
    let chartData: [DataPoint] = []
}
```

---

## Performance APIs

### Drawing Group Enhancements

```swift
struct DrawingGroupExample: View {
    var body: some View {
        // Flatten view hierarchy for GPU rendering
        ComplexGlassView()
            .drawingGroup(opaque: false, colorMode: .nonLinear)
        
        // New: Conditional drawing group
        ConditionalContent()
            .drawingGroup(if: shouldRasterize)
    }
    
    @State private var shouldRasterize = true
}
```

### Canvas Improvements

```swift
struct CanvasExample: View {
    var body: some View {
        Canvas { context, size in
            // New: Glass effect rendering
            context.fill(
                Path(roundedRect: CGRect(origin: .zero, size: size), 
                     cornerRadius: 20),
                with: .glassEffect()
            )
            
            // Draw content
            let text = Text("Canvas Content")
                .font(.title)
                .foregroundStyle(.primary)
            
            context.draw(text, at: CGPoint(x: size.width/2, y: size.height/2))
        }
        .frame(height: 200)
    }
}
```

### TimelineView Updates

```swift
struct TimelineViewExample: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { context in
            Canvas { gc, size in
                let angle = context.date.timeIntervalSinceReferenceDate * 2
                
                // Rotating glass effect
                gc.translateBy(x: size.width/2, y: size.height/2)
                gc.rotate(by: Angle(radians: angle))
                
                gc.fill(
                    Path(ellipseIn: CGRect(x: -50, y: -30, width: 100, height: 60)),
                    with: .color(.blue.opacity(0.5))
                )
            }
        }
        // New: Frame rate hint
        .preferredFrameRate(.high) // 120Hz on ProMotion
    }
}
```

---

## Platform Integration

### ShareLink Enhancements

```swift
struct ShareLinkExample: View {
    let item: ShareableItem
    
    var body: some View {
        ShareLink(item: item, preview: SharePreview(
            item.title,
            image: item.thumbnail
        )) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        // New: Share completion handler
        .onShareComplete { result in
            switch result {
            case .success(let activity):
                print("Shared via: \(activity)")
            case .failure(let error):
                print("Share failed: \(error)")
            }
        }
        // New: Custom share sheet style
        .shareSheetStyle(.glass)
    }
}
```

### PhotosPicker Updates

```swift
struct PhotosPickerExample: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    
    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 5,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Select Photos", systemImage: "photo.on.rectangle")
        }
        // New: Inline picker mode
        .photosPickerStyle(.inline)
        // New: Selection behavior
        .photosPickerDisabledCapabilities([.collectionNavigation])
        .onChange(of: selectedItems) { oldValue, newValue in
            Task {
                selectedImages = []
                for item in newValue {
                    if let image = try? await item.loadTransferable(type: Image.self) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}
```

### App Intents Integration

```swift
// Define app intent
struct OpenItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Item"
    static var description = IntentDescription("Opens a specific item in the app")
    
    @Parameter(title: "Item")
    var item: ItemEntity
    
    func perform() async throws -> some IntentResult {
        // Perform action
        return .result()
    }
}

// SwiftUI integration
struct IntentIntegrationExample: View {
    var body: some View {
        ItemCard(item: item)
            // New: Expose to Siri/Shortcuts
            .shortcutsLink(intent: OpenItemIntent(item: item.entity))
            // New: Spotlight indexing
            .spotlightSearchable(item.searchAttributes)
    }
    
    let item: Item
}
```

### Widget Integration

```swift
struct WidgetIntegrationExample: View {
    var body: some View {
        ContentView()
            // New: Widget-specific modifiers
            .widgetContainerBackground {
                // Glass effect in widgets
                ContainerRelativeShape()
                    .glassEffect()
            }
            // New: Widget URL handling
            .widgetURL(item.deepLink)
    }
    
    let item: Item
}
```

---

## Summary

iOS 26 SwiftUI introduces:

- **Glass effect modifiers** for the Liquid Glass design system
- **Enhanced navigation** with better transitions and state management
- **New view types** for common UI patterns
- **Improved animations** with phase and keyframe animators
- **Layout system updates** for responsive designs
- **Data flow enhancements** with Observable improvements
- **Advanced gesture handling** with velocity and composition
- **Accessibility APIs** for inclusive apps
- **Performance APIs** for smooth rendering
- **Platform integration** for system features

---

## Related Documentation

- [Liquid Glass Implementation](../liquid-glass/implementation.md)
- [Swift 6.2 Migration](../swift6/migration.md)
- [Complete Migration Checklist](../checklist/complete-guide.md)
