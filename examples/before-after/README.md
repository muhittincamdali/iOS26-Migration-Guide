# Before & After: iOS 26 Migration Examples

Real-world examples showing code transformations for iOS 26 migration.

## Contents

1. [Navigation Examples](#navigation-examples)
2. [Tab Bar Examples](#tab-bar-examples)
3. [Card Components](#card-components)
4. [Form Elements](#form-elements)
5. [Modal Presentations](#modal-presentations)
6. [List Views](#list-views)
7. [Concurrency Examples](#concurrency-examples)
8. [Custom Components](#custom-components)

---

## Navigation Examples

### Basic Navigation Bar

**Before (iOS 17):**
```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(item.title) {
                    DetailView(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        addItem()
                    }
                }
            }
        }
    }
}
```

**After (iOS 26):**
```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(item.title) {
                    DetailView(item: item)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .glassEffect(.subtle)
                )
            }
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        addItem()
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}
```

### Custom Navigation Bar

**Before (iOS 17):**
```swift
struct CustomNavBar: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Color.clear.frame(width: 44)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}
```

**After (iOS 26):**
```swift
struct CustomNavBar: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .padding(8)
                    .glassEffect(in: Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Color.clear.frame(width: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect()
    }
}
```

---

## Tab Bar Examples

### Standard Tab Bar

**Before (iOS 17):**
```swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
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
        }
        .tint(.blue)
    }
}
```

**After (iOS 26):**
```swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .tint(.blue)
        // Tab bar automatically uses glass in iOS 26
    }
}
```

### Floating Tab Bar

**Before (iOS 17):**
```swift
struct FloatingTabBar: View {
    @Binding var selection: Int
    
    var body: some View {
        HStack(spacing: 32) {
            ForEach(0..<4) { index in
                TabBarButton(
                    icon: icons[index],
                    isSelected: selection == index
                ) {
                    selection = index
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
    
    let icons = ["house", "magnifyingglass", "heart", "person"]
}
```

**After (iOS 26):**
```swift
struct FloatingTabBar: View {
    @Binding var selection: Int
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 32) {
            ForEach(0..<4) { index in
                TabBarButton(
                    icon: icons[index],
                    isSelected: selection == index,
                    namespace: namespace
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = index
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .glassEffect(.prominent, in: Capsule())
    }
    
    let icons = ["house", "magnifyingglass", "heart", "person"]
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "\(icon).fill" : icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .padding(12)
                .background {
                    if isSelected {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .matchedGeometryEffect(id: "indicator", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
```

---

## Card Components

### Info Card

**Before (iOS 17):**
```swift
struct InfoCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

**After (iOS 26):**
```swift
struct InfoCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .glassEffect(tint: .blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 16))
    }
}
```

### Feature Card

**Before (iOS 17):**
```swift
struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: feature.icon)
                    .font(.title)
                    .foregroundStyle(feature.color)
                
                Spacer()
                
                if feature.isNew {
                    Text("NEW")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            
            Text(feature.title)
                .font(.title3.bold())
            
            Text(feature.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            Spacer()
            
            Button("Learn More") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .frame(width: 280, height: 240)
        .background(
            LinearGradient(
                colors: [feature.color.opacity(0.1), feature.color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(feature.color.opacity(0.2), lineWidth: 1)
        }
    }
}
```

**After (iOS 26):**
```swift
struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: feature.icon)
                    .font(.title)
                    .foregroundStyle(feature.color)
                    .symbolEffect(.bounce, options: .speed(0.5))
                
                Spacer()
                
                if feature.isNew {
                    Text("NEW")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(tint: .orange.opacity(0.3), in: Capsule())
                }
            }
            
            Text(feature.title)
                .font(.title3.bold())
            
            Text(feature.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            Spacer()
            
            Button("Learn More") {
                // Action
            }
            .buttonStyle(.borderedProminent)
            .tint(feature.color)
        }
        .padding(20)
        .frame(width: 280, height: 240)
        .glassEffect(
            tint: feature.color.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}
```

---

## Form Elements

### Text Field

**Before (iOS 17):**
```swift
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .focused($isFocused)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isFocused ? Color.blue : Color.clear, lineWidth: 2)
            }
    }
}
```

**After (iOS 26):**
```swift
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(isFocused ? .primary : .secondary)
            }
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
        }
        .padding()
        .glassEffect(
            tint: isFocused ? .blue.opacity(0.1) : .clear,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isFocused ? Color.blue.opacity(0.5) : Color.clear,
                    lineWidth: 1.5
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
```

### Toggle Row

**Before (iOS 17):**
```swift
struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 28)
            
            Text(title)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**After (iOS 26):**
```swift
struct ToggleRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
                .symbolEffect(.bounce, value: isOn)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .glassEffect(.subtle, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## Modal Presentations

### Bottom Sheet

**Before (iOS 17):**
```swift
struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                    
                    content
                        .padding()
                }
                .background(Color(.systemBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.3), value: isPresented)
    }
}
```

**After (iOS 26):**
```swift
struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    @GestureState private var dragOffset: CGFloat = 0
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            isPresented = false
                        }
                    }
                
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 36, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    
                    content
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .glassEffect(in: UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    topTrailingRadius: 24
                ))
                .offset(y: max(0, dragOffset))
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation(.spring(response: 0.3)) {
                                    isPresented = false
                                }
                            }
                        }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
    }
}
```

### Alert Dialog

**Before (iOS 17):**
```swift
struct CustomAlert: View {
    let title: String
    let message: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            
            Text(title)
                .font(.title2.bold())
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    secondaryAction()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button("Confirm") {
                    primaryAction()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20)
        .padding(40)
    }
}
```

**After (iOS 26):**
```swift
struct CustomAlert: View {
    let title: String
    let message: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse)
            
            Text(title)
                .font(.title2.bold())
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    secondaryAction()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                
                Button("Confirm") {
                    primaryAction()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .glassEffect(
                    tint: .orange.opacity(0.8),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }
            .buttonStyle(.plain)
            .fontWeight(.semibold)
        }
        .padding(24)
        .glassEffect(.prominent, in: RoundedRectangle(cornerRadius: 24))
        .padding(40)
    }
}
```

---

## List Views

### Settings List

**Before (iOS 17):**
```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                SettingsRow(icon: "person.fill", title: "Profile", color: .blue)
                SettingsRow(icon: "bell.fill", title: "Notifications", color: .red)
                SettingsRow(icon: "lock.fill", title: "Privacy", color: .green)
            }
            
            Section("Preferences") {
                SettingsRow(icon: "paintbrush.fill", title: "Appearance", color: .purple)
                SettingsRow(icon: "globe", title: "Language", color: .orange)
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(title)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

**After (iOS 26):**
```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section {
                SettingsRow(icon: "person.fill", title: "Profile", subtitle: "Name, email, photo", color: .blue)
                SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Alerts, sounds, badges", color: .red)
                SettingsRow(icon: "lock.fill", title: "Privacy", subtitle: "Permissions, data", color: .green)
            } header: {
                Text("Account")
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .glassEffect(.subtle)
                    .padding(.vertical, 2)
            )
            
            Section {
                SettingsRow(icon: "paintbrush.fill", title: "Appearance", subtitle: "Theme, colors", color: .purple)
                SettingsRow(icon: "globe", title: "Language", subtitle: "English", color: .orange)
            } header: {
                Text("Preferences")
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .glassEffect(.subtle)
                    .padding(.vertical, 2)
            )
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .glassEffect(tint: color, in: RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
```

---

## Concurrency Examples

### Network Request

**Before (iOS 17 - Completion Handler):**
```swift
class NetworkManager {
    func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "https://api.example.com/users/\(id)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// Usage
networkManager.fetchUser(id: "123") { result in
    switch result {
    case .success(let user):
        self.user = user
    case .failure(let error):
        self.error = error
    }
}
```

**After (iOS 26 - Async/Await):**
```swift
actor NetworkManager {
    func fetchUser(id: String) async throws -> User {
        let url = URL(string: "https://api.example.com/users/\(id)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func fetchUsers(ids: [String]) async throws -> [User] {
        try await withThrowingTaskGroup(of: User.self) { group in
            for id in ids {
                group.addTask {
                    try await self.fetchUser(id: id)
                }
            }
            
            var users: [User] = []
            for try await user in group {
                users.append(user)
            }
            return users
        }
    }
}

// Usage
Task {
    do {
        let user = try await networkManager.fetchUser(id: "123")
        await MainActor.run {
            self.user = user
        }
    } catch {
        await MainActor.run {
            self.error = error
        }
    }
}
```

### ViewModel Pattern

**Before (iOS 17):**
```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkManager = NetworkManager()
    
    func loadUsers() {
        isLoading = true
        error = nil
        
        networkManager.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
```

**After (iOS 26):**
```swift
@MainActor
@Observable
class UserViewModel {
    var users: [User] = []
    var isLoading = false
    var error: Error?
    
    private let networkManager = NetworkManager()
    
    func loadUsers() async {
        isLoading = true
        error = nil
        
        do {
            users = try await networkManager.fetchUsers(ids: userIds)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    private let userIds = ["1", "2", "3", "4", "5"]
}

// Usage in SwiftUI
struct UsersView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .task {
            await viewModel.loadUsers()
        }
        .refreshable {
            await viewModel.loadUsers()
        }
    }
}
```

---

## Custom Components

### Loading Button

**Before (iOS 17):**
```swift
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
    }
}
```

**After (iOS 26):**
```swift
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let style: ButtonStyle
    let action: () async -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(style.foregroundColor)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(style.foregroundColor)
            .glassEffect(
                tint: style.tintColor,
                in: RoundedRectangle(cornerRadius: 14)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .destructive: return .white
            }
        }
        
        var tintColor: Color {
            switch self {
            case .primary: return .blue.opacity(0.9)
            case .secondary: return .clear
            case .destructive: return .red.opacity(0.9)
            }
        }
    }
}
```

---

## Summary

Key transformation patterns for iOS 26:

| Component | iOS 17 | iOS 26 |
|-----------|--------|--------|
| Backgrounds | Solid colors | `.glassEffect()` |
| Shadows | Drop shadows | Reduced/removed |
| Corners | Fixed radius | Continuous curves |
| Buttons | Bordered style | Glass capsules |
| Lists | System background | Glass rows |
| Modals | Solid sheets | Glass sheets |
| Network | Completion handlers | async/await |
| ViewModels | ObservableObject | @Observable |

---

## Related Documentation

- [Liquid Glass Implementation](../../docs/liquid-glass/implementation.md)
- [SwiftUI New APIs](../../docs/swiftui/new-apis.md)
- [Common Issues](../common-issues/README.md)
