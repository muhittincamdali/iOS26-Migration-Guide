# Liquid Glass Best Practices

Essential guidelines and patterns for implementing Liquid Glass effectively in iOS 26.

## Table of Contents

1. [Design Principles](#design-principles)
2. [Material Selection](#material-selection)
3. [Layout Guidelines](#layout-guidelines)
4. [Typography on Glass](#typography-on-glass)
5. [Color Management](#color-management)
6. [Icons and Imagery](#icons-and-imagery)
7. [Interactive States](#interactive-states)
8. [Common Patterns](#common-patterns)
9. [Anti-Patterns](#anti-patterns)
10. [Testing Strategies](#testing-strategies)

---

## Design Principles

### Hierarchy Through Transparency

Use transparency levels to establish visual hierarchy:

```swift
// Primary content - least transparent
struct PrimaryContent: View {
    var body: some View {
        VStack {
            Text("Important Action")
                .font(.headline)
        }
        .padding()
        .glassEffect(.prominent)
    }
}

// Secondary content - medium transparency
struct SecondaryContent: View {
    var body: some View {
        VStack {
            Text("Supporting Info")
                .font(.subheadline)
        }
        .padding()
        .glassEffect()
    }
}

// Tertiary content - most transparent
struct TertiaryContent: View {
    var body: some View {
        Text("Additional Details")
            .font(.caption)
            .padding()
            .glassEffect(.subtle)
    }
}
```

### Content-First Design

Glass should enhance, not compete with content:

```swift
// Good: Content is clearly visible
struct ContentFocusedCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // High-contrast text
            Text(article.title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            Text(article.excerpt)
                .font(.body)
                .foregroundStyle(.secondary)
            
            HStack {
                Label(article.author, systemImage: "person")
                Spacer()
                Label(article.readTime, systemImage: "clock")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(20)
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct Article {
    let title: String
    let excerpt: String
    let author: String
    let readTime: String
}
```

### Environmental Awareness

Design for varying backgrounds:

```swift
struct AdaptiveGlassCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text("Adaptive Content")
                .font(.headline)
            Text("Adjusts to environment")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .glassEffect(
            tint: colorScheme == .dark 
                ? .white.opacity(0.05) 
                : .black.opacity(0.02)
        )
    }
}
```

### Purposeful Use

Apply glass only where it adds value:

```swift
// Good: Glass adds depth to floating elements
struct FloatingActionPanel: View {
    var body: some View {
        HStack(spacing: 20) {
            ActionButton(icon: "heart", label: "Like")
            ActionButton(icon: "square.and.arrow.up", label: "Share")
            ActionButton(icon: "bookmark", label: "Save")
        }
        .padding(16)
        .glassEffect(.prominent, in: Capsule())
    }
}

// Avoid: Glass on every element
struct OverusedGlass: View {
    var body: some View {
        VStack {
            Text("Title").glassEffect() // Unnecessary
            Text("Body").glassEffect()  // Unnecessary
            Button("Action") {}.glassEffect() // Unnecessary
        }
        // Better: Single glass container
    }
}
```

---

## Material Selection

### When to Use Each Material

```swift
struct MaterialShowcase: View {
    var body: some View {
        VStack(spacing: 24) {
            // Ultra thin - Background elements, large surfaces
            DemoCard(title: "Ultra Thin", subtitle: "Background panels, sidebars")
                .background(.ultraThinMaterial)
            
            // Thin - Overlays, secondary panels
            DemoCard(title: "Thin", subtitle: "Modal sheets, popovers")
                .background(.thinMaterial)
            
            // Regular - Standard UI elements
            DemoCard(title: "Regular", subtitle: "Cards, navigation bars")
                .background(.regularMaterial)
            
            // Thick - High visibility elements
            DemoCard(title: "Thick", subtitle: "Alerts, important actions")
                .background(.thickMaterial)
            
            // Ultra thick - Maximum readability
            DemoCard(title: "Ultra Thick", subtitle: "Critical information")
                .background(.ultraThickMaterial)
        }
    }
}

struct DemoCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

### Material Contexts

Choose materials based on context:

```swift
struct ContextualMaterials: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen content background
                ContentBackground()
                
                VStack {
                    // Navigation uses regular material
                    CustomNavBar()
                        .background(.regularMaterial)
                    
                    // Content cards use thin material
                    ScrollView {
                        ForEach(0..<10) { _ in
                            ContentCard()
                                .background(.thinMaterial)
                        }
                    }
                    
                    // Tab bar uses regular material
                    CustomTabBar()
                        .background(.regularMaterial)
                }
            }
        }
    }
}
```

### Dynamic Material Adjustment

Adjust materials based on content:

```swift
struct DynamicMaterialCard: View {
    let backgroundLuminance: CGFloat
    
    var material: Material {
        if backgroundLuminance < 0.3 {
            // Dark background - use lighter material
            return .thinMaterial
        } else if backgroundLuminance > 0.7 {
            // Light background - use standard material
            return .regularMaterial
        } else {
            // Mixed background - use thicker material
            return .thickMaterial
        }
    }
    
    var body: some View {
        Text("Dynamic Material")
            .padding()
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## Layout Guidelines

### Spacing Recommendations

```swift
struct SpacingGuidelines: View {
    var body: some View {
        VStack(spacing: 24) {
            // Compact glass elements
            HStack(spacing: 8) {
                CompactGlassButton(icon: "star")
                CompactGlassButton(icon: "heart")
                CompactGlassButton(icon: "bookmark")
            }
            
            // Standard glass cards
            VStack(spacing: 16) {
                StandardGlassCard(title: "First Item")
                StandardGlassCard(title: "Second Item")
            }
            
            // Large glass panels
            VStack(spacing: 24) {
                LargeGlassPanel(content: "Panel One")
                LargeGlassPanel(content: "Panel Two")
            }
        }
        .padding()
    }
}

struct CompactGlassButton: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .padding(12)
            .glassEffect(in: Circle())
    }
}

struct StandardGlassCard: View {
    let title: String
    
    var body: some View {
        Text(title)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct LargeGlassPanel: View {
    let content: String
    
    var body: some View {
        Text(content)
            .padding(24)
            .frame(maxWidth: .infinity)
            .glassEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}
```

### Corner Radius Guidelines

| Element Size | Recommended Radius |
|-------------|-------------------|
| Small (< 44pt) | 8-12pt |
| Medium (44-100pt) | 12-16pt |
| Large (100-200pt) | 16-20pt |
| Extra Large (> 200pt) | 20-32pt |

```swift
struct CornerRadiusExamples: View {
    var body: some View {
        VStack(spacing: 20) {
            // Small element
            Text("S")
                .frame(width: 40, height: 40)
                .glassEffect(in: RoundedRectangle(cornerRadius: 10))
            
            // Medium element
            Text("Medium")
                .frame(width: 120, height: 60)
                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            
            // Large element
            VStack {
                Text("Large Panel")
                Text("With more content")
            }
            .padding()
            .frame(width: 200, height: 120)
            .glassEffect(in: RoundedRectangle(cornerRadius: 18))
            
            // Extra large element
            VStack {
                Text("Extra Large")
                Text("Full-width card with substantial content")
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .glassEffect(in: RoundedRectangle(cornerRadius: 24))
        }
        .padding()
    }
}
```

### Safe Area Considerations

```swift
struct SafeAreaGlassLayout: View {
    var body: some View {
        ZStack {
            // Background content
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header respects safe area
                HeaderView()
                    .glassEffect()
                    .safeAreaPadding(.top)
                
                // Main content
                ScrollView {
                    ContentView()
                }
                
                // Footer with safe area
                FooterView()
                    .glassEffect()
                    .safeAreaPadding(.bottom)
            }
        }
        .ignoresSafeArea()
    }
}
```

### Grid Layouts with Glass

```swift
struct GlassGridLayout: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<12) { index in
                    GlassGridItem(index: index)
                }
            }
            .padding()
        }
    }
}

struct GlassGridItem: View {
    let index: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("Item \(index + 1)")
                .font(.caption)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

---

## Typography on Glass

### Font Weight Guidelines

```swift
struct TypographyOnGlass: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Headlines - use semibold or bold
            Text("Headlines Need Weight")
                .font(.title.bold())
            
            // Subheadlines - use medium or semibold
            Text("Subheadlines Medium Weight")
                .font(.headline)
            
            // Body text - regular weight is fine
            Text("Body text can use regular weight when the glass material provides sufficient contrast.")
                .font(.body)
            
            // Captions - consider slightly heavier
            Text("Captions might need medium weight")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}
```

### Text Contrast Strategies

```swift
struct TextContrastStrategies: View {
    var body: some View {
        VStack(spacing: 24) {
            // Strategy 1: Shadow for depth
            Text("Shadow Text")
                .font(.title2.bold())
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                .padding()
                .glassEffect()
            
            // Strategy 2: Vibrancy effect
            Text("Vibrant Text")
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .padding()
                .glassEffect()
            
            // Strategy 3: Background pill
            HStack {
                Text("Pill Background")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding()
            .glassEffect(.subtle)
        }
    }
}
```

### Adaptive Text Colors

```swift
struct AdaptiveTextColors: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Primary Text")
                .foregroundStyle(.primary)
            
            Text("Secondary Text")
                .foregroundStyle(.secondary)
            
            Text("Accent Text")
                .foregroundStyle(adaptiveAccentColor)
        }
        .padding()
        .glassEffect()
    }
    
    var adaptiveAccentColor: Color {
        colorScheme == .dark 
            ? .blue.opacity(0.9) 
            : .blue
    }
}
```

---

## Color Management

### Tint Application

```swift
struct TintApplication: View {
    var body: some View {
        VStack(spacing: 20) {
            // Subtle brand tint
            BrandCard(color: .blue, intensity: 0.1)
            
            // Category indicators
            CategoryCard(category: "Work", color: .red)
            CategoryCard(category: "Personal", color: .green)
            CategoryCard(category: "Finance", color: .purple)
        }
        .padding()
    }
}

struct BrandCard: View {
    let color: Color
    let intensity: Double
    
    var body: some View {
        VStack {
            Text("Brand Tinted Card")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(tint: color.opacity(intensity))
    }
}

struct CategoryCard: View {
    let category: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(category)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .glassEffect(tint: color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
```

### Status Colors on Glass

```swift
struct StatusColorsOnGlass: View {
    var body: some View {
        VStack(spacing: 16) {
            StatusBadge(status: .success)
            StatusBadge(status: .warning)
            StatusBadge(status: .error)
            StatusBadge(status: .info)
        }
        .padding()
    }
}

struct StatusBadge: View {
    let status: Status
    
    var body: some View {
        HStack {
            Image(systemName: status.icon)
                .foregroundStyle(status.color)
            
            Text(status.message)
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .glassEffect(tint: status.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(status.color.opacity(0.3), lineWidth: 1)
        }
    }
    
    enum Status {
        case success, warning, error, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var message: String {
            switch self {
            case .success: return "Operation completed successfully"
            case .warning: return "Please review before continuing"
            case .error: return "An error occurred"
            case .info: return "Additional information available"
            }
        }
    }
}
```

### Gradient Considerations

```swift
struct GradientOnGlass: View {
    var body: some View {
        VStack(spacing: 20) {
            // Subtle gradient overlay
            Text("Gradient Accent")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.15), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .glassEffect()
                }
            
            // Border gradient
            Text("Gradient Border")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
        }
        .padding()
    }
}
```

---

## Icons and Imagery

### Icon Treatment on Glass

```swift
struct IconTreatment: View {
    var body: some View {
        HStack(spacing: 20) {
            // Filled icons work best
            IconButton(
                icon: "heart.fill",
                label: "Filled",
                style: .filled
            )
            
            // Outlined need more weight
            IconButton(
                icon: "heart",
                label: "Outlined",
                style: .outlined
            )
            
            // Symbols with background
            IconButton(
                icon: "star.fill",
                label: "Background",
                style: .background
            )
        }
    }
}

struct IconButton: View {
    let icon: String
    let label: String
    let style: IconStyle
    
    var body: some View {
        VStack(spacing: 8) {
            Group {
                switch style {
                case .filled:
                    Image(systemName: icon)
                        .font(.title2)
                        
                case .outlined:
                    Image(systemName: icon)
                        .font(.title2.weight(.medium))
                        
                case .background:
                    Image(systemName: icon)
                        .font(.title3)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            Text(label)
                .font(.caption2)
        }
        .padding()
        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    }
    
    enum IconStyle {
        case filled, outlined, background
    }
}
```

### Image Integration

```swift
struct ImageIntegration: View {
    var body: some View {
        VStack(spacing: 20) {
            // Image with glass overlay
            ZStack(alignment: .bottom) {
                Image("landscape")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                
                HStack {
                    Text("Photo Title")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "heart.fill")
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Image inside glass card
            HStack(spacing: 16) {
                Image("avatar")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("User Name")
                        .font(.headline)
                    Text("@username")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
```

### SF Symbols Best Practices

```swift
struct SFSymbolsBestPractices: View {
    var body: some View {
        VStack(spacing: 24) {
            // Hierarchical rendering
            Label {
                Text("Hierarchical")
            } icon: {
                Image(systemName: "square.stack.3d.up.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
            }
            .padding()
            .glassEffect()
            
            // Palette rendering
            Label {
                Text("Palette")
            } icon: {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.primary, .green)
            }
            .padding()
            .glassEffect()
            
            // Variable value
            SymbolVariableDemo()
        }
    }
}

struct SymbolVariableDemo: View {
    @State private var value: Double = 0.7
    
    var body: some View {
        VStack {
            Image(systemName: "speaker.wave.3.fill", variableValue: value)
                .font(.title)
            
            Slider(value: $value)
        }
        .padding()
        .glassEffect()
    }
}
```

---

## Interactive States

### Button States

```swift
struct GlassButtonStates: View {
    @State private var isDisabled = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Normal state
            InteractiveGlassButton(title: "Normal", state: .normal) {}
            
            // Hover state (iPadOS/macOS)
            InteractiveGlassButton(title: "Hovered", state: .hovered) {}
            
            // Pressed state
            InteractiveGlassButton(title: "Pressed", state: .pressed) {}
            
            // Disabled state
            InteractiveGlassButton(title: "Disabled", state: .disabled) {}
            
            // Loading state
            InteractiveGlassButton(title: "Loading", state: .loading) {}
        }
        .padding()
    }
}

struct InteractiveGlassButton: View {
    let title: String
    let state: ButtonState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if state == .loading {
                    ProgressView()
                        .tint(.primary)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .glassEffect(
                tint: state.tintColor,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .opacity(state.opacity)
            .scaleEffect(state.scale)
        }
        .buttonStyle(.plain)
        .disabled(state == .disabled || state == .loading)
    }
    
    enum ButtonState {
        case normal, hovered, pressed, disabled, loading
        
        var tintColor: Color {
            switch self {
            case .normal: return .clear
            case .hovered: return .blue.opacity(0.1)
            case .pressed: return .blue.opacity(0.2)
            case .disabled: return .gray.opacity(0.1)
            case .loading: return .clear
            }
        }
        
        var opacity: Double {
            self == .disabled ? 0.5 : 1.0
        }
        
        var scale: CGFloat {
            self == .pressed ? 0.98 : 1.0
        }
    }
}
```

### Focus States

```swift
struct FocusStatesDemo: View {
    @FocusState private var focusedField: Field?
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            FocusableGlassField(
                placeholder: "Username",
                text: $username,
                isFocused: focusedField == .username
            )
            .focused($focusedField, equals: .username)
            
            FocusableGlassField(
                placeholder: "Password",
                text: $password,
                isFocused: focusedField == .password,
                isSecure: true
            )
            .focused($focusedField, equals: .password)
        }
        .padding()
    }
    
    enum Field {
        case username, password
    }
}

struct FocusableGlassField: View {
    let placeholder: String
    @Binding var text: String
    let isFocused: Bool
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .glassEffect(
            tint: isFocused ? .blue.opacity(0.1) : .clear,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isFocused ? .blue : .clear,
                    lineWidth: 2
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
```

### Selection States

```swift
struct SelectionStatesDemo: View {
    @State private var selectedItems: Set<String> = []
    let items = ["Item A", "Item B", "Item C", "Item D"]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items, id: \.self) { item in
                SelectableGlassRow(
                    title: item,
                    isSelected: selectedItems.contains(item)
                ) {
                    if selectedItems.contains(item) {
                        selectedItems.remove(item)
                    } else {
                        selectedItems.insert(item)
                    }
                }
            }
        }
        .padding()
    }
}

struct SelectableGlassRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .padding()
            .glassEffect(
                tint: isSelected ? .blue.opacity(0.1) : .clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
```

---

## Common Patterns

### Modal Sheets

```swift
struct GlassModalSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary.opacity(0.5))
                .frame(width: 36, height: 5)
            
            // Header
            HStack {
                Text("Sheet Title")
                    .font(.title2.bold())
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content
            VStack(spacing: 16) {
                GlassOptionRow(icon: "gear", title: "Settings")
                GlassOptionRow(icon: "person", title: "Profile")
                GlassOptionRow(icon: "bell", title: "Notifications")
            }
            
            Spacer()
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

struct GlassOptionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

### Toast Notifications

```swift
struct GlassToast: View {
    let message: String
    let icon: String
    let type: ToastType
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(type.color)
            
            Text(message)
                .font(.subheadline.weight(.medium))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(
            .prominent,
            tint: type.color.opacity(0.1),
            in: Capsule()
        )
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    enum ToastType {
        case success, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
}

// Usage with animation
struct ToastPresenter: View {
    @State private var showToast = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ContentView()
            
            if showToast {
                GlassToast(
                    message: "Changes saved successfully",
                    icon: "checkmark.circle.fill",
                    type: .success
                )
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: showToast)
    }
}
```

### Contextual Menus

```swift
struct GlassContextMenu: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            MenuOption(icon: "doc.on.doc", title: "Copy", shortcut: "⌘C")
            MenuOption(icon: "scissors", title: "Cut", shortcut: "⌘X")
            MenuOption(icon: "doc.on.clipboard", title: "Paste", shortcut: "⌘V")
            
            Divider()
                .padding(.vertical, 4)
            
            MenuOption(icon: "trash", title: "Delete", isDestructive: true)
        }
        .padding(8)
        .glassEffect(.prominent, in: RoundedRectangle(cornerRadius: 12))
        .frame(width: 200)
    }
}

struct MenuOption: View {
    let icon: String
    let title: String
    var shortcut: String? = nil
    var isDestructive: Bool = false
    
    var body: some View {
        Button {
            // Action
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                Spacer()
                if let shortcut {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(isDestructive ? .red : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
```

---

## Anti-Patterns

### What to Avoid

```swift
// AVOID: Glass on glass stacking
struct AvoidGlassOnGlass: View {
    var body: some View {
        VStack {
            Text("Content")
        }
        .padding()
        .glassEffect()
        .padding()
        .glassEffect() // Double glass effect - avoid!
    }
}

// AVOID: Too many glass elements
struct AvoidTooManyGlass: View {
    var body: some View {
        VStack {
            Text("Title").padding().glassEffect()
            Text("Subtitle").padding().glassEffect()
            Text("Body").padding().glassEffect()
            Button("Action") {}.padding().glassEffect()
            // Each element has glass - overwhelming!
        }
    }
}

// AVOID: Glass with solid backgrounds
struct AvoidSolidBackgrounds: View {
    var body: some View {
        VStack {
            Text("Content")
        }
        .padding()
        .background(Color.blue) // Solid color defeats glass purpose
        .glassEffect()
    }
}

// AVOID: Small text on light glass
struct AvoidSmallTextOnLightGlass: View {
    var body: some View {
        Text("Tiny hard to read text")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding()
            .glassEffect(.subtle) // Low contrast = poor readability
    }
}
```

### Better Alternatives

```swift
// BETTER: Single glass container
struct BetterSingleContainer: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Title").font(.headline)
            Text("Subtitle").font(.subheadline)
            Text("Body")
            Button("Action") {}
        }
        .padding()
        .glassEffect() // One glass effect for all
    }
}

// BETTER: Appropriate text contrast
struct BetterTextContrast: View {
    var body: some View {
        Text("Readable caption text")
            .font(.caption.weight(.medium))
            .foregroundStyle(.primary)
            .padding()
            .glassEffect(.regular) // More opaque material
    }
}

// BETTER: Strategic glass usage
struct BetterStrategicUsage: View {
    var body: some View {
        ZStack {
            // Background content
            ContentBackground()
            
            // Only floating elements use glass
            VStack {
                Spacer()
                FloatingActionBar()
                    .glassEffect(.prominent)
            }
        }
    }
}
```

---

## Testing Strategies

### Visual Testing Checklist

```swift
struct VisualTestingChecklist: View {
    var body: some View {
        List {
            Section("Background Variations") {
                Text("✓ Light solid backgrounds")
                Text("✓ Dark solid backgrounds")
                Text("✓ Photographic backgrounds")
                Text("✓ Gradient backgrounds")
                Text("✓ Dynamic wallpapers")
            }
            
            Section("Mode Testing") {
                Text("✓ Light mode appearance")
                Text("✓ Dark mode appearance")
                Text("✓ High contrast mode")
                Text("✓ Reduced transparency")
            }
            
            Section("Device Testing") {
                Text("✓ iPhone (various sizes)")
                Text("✓ iPad")
                Text("✓ Mac (Catalyst/native)")
            }
        }
    }
}
```

### Accessibility Testing

```swift
struct AccessibilityTestingGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accessibility Testing Guide")
                .font(.headline)
            
            Group {
                TestItem(
                    title: "VoiceOver Navigation",
                    description: "All glass elements should be properly labeled"
                )
                
                TestItem(
                    title: "Reduce Transparency",
                    description: "UI should remain usable with opaque backgrounds"
                )
                
                TestItem(
                    title: "Increase Contrast",
                    description: "Text should remain readable with higher contrast"
                )
                
                TestItem(
                    title: "Reduce Motion",
                    description: "Animations should simplify or disable"
                )
                
                TestItem(
                    title: "Dynamic Type",
                    description: "Glass containers should scale appropriately"
                )
            }
        }
        .padding()
    }
}

struct TestItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.bold())
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 8))
    }
}
```

### Performance Testing

```swift
struct PerformanceTestingMetrics: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Performance Metrics")
                .font(.headline)
            
            MetricRow(
                name: "Frame Rate",
                target: "60 FPS sustained",
                tool: "Instruments > Core Animation"
            )
            
            MetricRow(
                name: "GPU Utilization",
                target: "< 50% during scrolling",
                tool: "Instruments > GPU"
            )
            
            MetricRow(
                name: "Memory",
                target: "No leaks, stable allocation",
                tool: "Instruments > Allocations"
            )
            
            MetricRow(
                name: "Energy",
                target: "Low energy impact",
                tool: "Instruments > Energy Log"
            )
        }
        .padding()
    }
}

struct MetricRow: View {
    let name: String
    let target: String
    let tool: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.subheadline.bold())
            
            HStack {
                Label(target, systemImage: "target")
                    .font(.caption)
            }
            
            Text(tool)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## Summary

Following these best practices ensures your Liquid Glass implementation:

1. **Enhances rather than distracts** from content
2. **Maintains readability** across all contexts
3. **Performs efficiently** without battery drain
4. **Remains accessible** to all users
5. **Feels natural** and iOS-native

Remember: Glass effects are powerful tools, but restraint creates elegance.

---

## Related Documentation

- [Implementation Guide](./implementation.md)
- [SwiftUI New APIs](../swiftui/new-apis.md)
- [Complete Migration Checklist](../checklist/complete-guide.md)
