# StoreKit Migration for iOS 26

> Back to [main guide](../../README.md)

Complete guide for migrating In-App Purchases to StoreKit 2 and iOS 26 enhancements.

---

## Table of Contents

- [What's New](#whats-new)
- [StoreKit 1 to StoreKit 2](#storekit-1-to-storekit-2)
- [New iOS 26 Features](#new-ios-26-features)
- [Subscription Management](#subscription-management)
- [Transaction Handling](#transaction-handling)
- [Testing](#testing)

---

## What's New

iOS 26 StoreKit updates:

| Feature | Description |
|---------|-------------|
| **Age Rating API** | Query content age ratings |
| **Offer Code Improvements** | One-time use codes support |
| **Transaction History** | Enhanced filtering and sorting |
| **Price Localization** | Improved multi-currency support |
| **Subscription Groups** | Better group management |
| **Refund Requests** | In-app refund request flow |

---

## StoreKit 1 to StoreKit 2

### Product Loading

```swift
// ❌ iOS 25 - StoreKit 1 (deprecated)
import StoreKit

class StoreManager: NSObject, SKProductsRequestDelegate {
    var products: [SKProduct] = []
    
    func loadProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(["premium_monthly", "premium_yearly"]))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }
}

// ✅ iOS 26 - StoreKit 2
import StoreKit

actor StoreManager {
    private(set) var products: [Product] = []
    
    func loadProducts() async throws {
        products = try await Product.products(for: [
            "premium_monthly",
            "premium_yearly"
        ])
    }
    
    var monthlySubscription: Product? {
        products.first { $0.id == "premium_monthly" }
    }
    
    var yearlySubscription: Product? {
        products.first { $0.id == "premium_yearly" }
    }
}
```

### Purchase Flow

```swift
// ❌ iOS 25 - StoreKit 1 (deprecated)
class PurchaseManager: NSObject, SKPaymentTransactionObserver {
    func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Unlock content
                queue.finishTransaction(transaction)
            case .failed:
                // Handle error
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
    }
}

// ✅ iOS 26 - StoreKit 2
actor PurchaseManager {
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Verify the transaction
            let transaction = try checkVerified(verification)
            
            // Unlock content
            await unlockContent(for: transaction)
            
            // Finish the transaction
            await transaction.finish()
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            // Transaction is pending (e.g., Ask to Buy)
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let item):
            return item
        }
    }
}
```

### Transaction Listening

```swift
// ❌ iOS 25 - SKPaymentTransactionObserver
SKPaymentQueue.default().add(self)

// ✅ iOS 26 - Task-based listening
@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isPremium = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.productType == .autoRenewable {
                isPremium = transaction.revocationDate == nil
            }
        }
    }
}
```

---

## New iOS 26 Features

### Age Rating API

```swift
// ✅ iOS 26 - Query age ratings
func checkAgeRating() async throws {
    guard let appTransaction = try? await AppTransaction.shared else { return }
    
    switch appTransaction.verificationResult {
    case .verified(let transaction):
        // New in iOS 26
        if let ageRating = transaction.ageRating {
            switch ageRating {
            case .fourPlus:
                // Suitable for 4+
                break
            case .ninePlus:
                // Suitable for 9+
                break
            case .twelvePlus:
                // Suitable for 12+
                break
            case .seventeenPlus:
                // Suitable for 17+
                break
            @unknown default:
                break
            }
        }
    case .unverified(_, _):
        break
    }
}
```

### Enhanced Offer Codes

```swift
// ✅ iOS 26 - One-time use offer codes
struct OfferCodeRedemption: View {
    @State private var showingOfferCodeSheet = false
    
    var body: some View {
        Button("Redeem Offer Code") {
            showingOfferCodeSheet = true
        }
        .offerCodeRedemption(isPresented: $showingOfferCodeSheet) { result in
            switch result {
            case .success:
                // Code redeemed successfully
                Task {
                    await refreshPurchases()
                }
            case .failure(let error):
                // Handle error
                print("Redemption failed: \(error)")
            }
        }
    }
}

// Programmatic offer code validation
func validateOfferCode(_ code: String) async throws -> Bool {
    // iOS 26 - Enhanced validation
    let products = try await Product.products(for: ["premium_yearly"])
    
    guard let product = products.first else { return false }
    
    // Check if code is valid for this product
    for offer in product.subscription?.promotionalOffers ?? [] {
        if offer.id == code {
            return true
        }
    }
    
    return false
}
```

### In-App Refund Requests

```swift
// ✅ iOS 26 - Request refund from within app
struct PurchaseHistoryView: View {
    let transaction: Transaction
    @State private var showingRefundSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(transaction.productID)
                .font(.headline)
            
            Text("Purchased: \(transaction.purchaseDate.formatted())")
                .font(.caption)
            
            Button("Request Refund") {
                showingRefundSheet = true
            }
            .refundRequestSheet(
                for: transaction.id,
                isPresented: $showingRefundSheet
            ) { result in
                switch result {
                case .success(.success):
                    // Refund approved
                    break
                case .success(.userCancelled):
                    // User cancelled request
                    break
                case .failure(let error):
                    print("Refund request failed: \(error)")
                }
            }
        }
    }
}
```

### Transaction History Filtering

```swift
// ✅ iOS 26 - Enhanced transaction history
func loadTransactionHistory() async {
    // All transactions
    for await result in Transaction.all {
        guard case .verified(let transaction) = result else { continue }
        processTransaction(transaction)
    }
    
    // Filter by product type
    for await result in Transaction.all.filter({ result in
        guard case .verified(let transaction) = result else { return false }
        return transaction.productType == .autoRenewable
    }) {
        // Only subscription transactions
    }
    
    // iOS 26 - New filtering options
    let recentTransactions = Transaction.all
        .filter { result in
            guard case .verified(let transaction) = result else { return false }
            return transaction.purchaseDate > Date().addingTimeInterval(-30 * 24 * 60 * 60)
        }
    
    for await result in recentTransactions {
        // Last 30 days transactions
    }
}
```

---

## Subscription Management

### Subscription Status

```swift
// ✅ iOS 26 - Enhanced subscription status
actor SubscriptionStatusManager {
    func checkSubscriptionStatus() async throws -> SubscriptionStatus {
        // Get current entitlements
        var activeSubscription: Transaction?
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.productType == .autoRenewable {
                activeSubscription = transaction
                break
            }
        }
        
        guard let subscription = activeSubscription else {
            return .notSubscribed
        }
        
        // Check renewal info
        if let renewalInfo = try? await subscription.subscriptionStatus?.first?.renewalInfo {
            switch renewalInfo {
            case .verified(let info):
                if info.willAutoRenew {
                    return .active(expiresDate: subscription.expirationDate)
                } else {
                    return .expiring(expiresDate: subscription.expirationDate)
                }
            case .unverified(_, _):
                return .unknown
            }
        }
        
        return .unknown
    }
}

enum SubscriptionStatus {
    case notSubscribed
    case active(expiresDate: Date?)
    case expiring(expiresDate: Date?)
    case expired
    case unknown
}
```

### Subscription Groups

```swift
// ✅ iOS 26 - Manage subscription groups
struct SubscriptionGroupView: View {
    let groupID: String
    @State private var products: [Product] = []
    @State private var currentSubscription: Product.SubscriptionInfo.Status?
    
    var body: some View {
        VStack {
            ForEach(products, id: \.id) { product in
                SubscriptionOptionView(
                    product: product,
                    isCurrentPlan: isCurrentPlan(product)
                )
            }
        }
        .task {
            await loadSubscriptionGroup()
        }
    }
    
    func loadSubscriptionGroup() async {
        // Load products in the group
        products = try? await Product.products(for: [
            "premium_monthly",
            "premium_yearly",
            "premium_lifetime"
        ]).filter { $0.subscription?.subscriptionGroupID == groupID }
        
        // Get current subscription in this group
        if let statuses = try? await products.first?.subscription?.status {
            currentSubscription = statuses.first
        }
    }
    
    func isCurrentPlan(_ product: Product) -> Bool {
        guard case .verified(let renewalInfo) = currentSubscription?.renewalInfo else {
            return false
        }
        return renewalInfo.currentProductID == product.id
    }
}
```

### Upgrade/Downgrade Flow

```swift
// ✅ iOS 26 - Handle subscription changes
func changeSubscription(to newProduct: Product, from currentProduct: Product) async throws {
    // Determine if upgrade or downgrade
    let currentPrice = currentProduct.price
    let newPrice = newProduct.price
    
    let options: Set<Product.PurchaseOption>
    
    if newPrice > currentPrice {
        // Upgrade - takes effect immediately
        options = [.promotionalOffer(/* offer if available */)]
    } else {
        // Downgrade - takes effect at next renewal
        options = []
    }
    
    let result = try await newProduct.purchase(options: options)
    
    switch result {
    case .success(let verification):
        let transaction = try checkVerified(verification)
        await transaction.finish()
        
        // Notify user of the change
        await notifySubscriptionChange(
            from: currentProduct,
            to: newProduct,
            isImmediate: newPrice > currentPrice
        )
        
    case .userCancelled, .pending:
        break
        
    @unknown default:
        break
    }
}
```

---

## Transaction Handling

### Robust Transaction Processing

```swift
// ✅ iOS 26 - Comprehensive transaction handling
actor TransactionProcessor {
    func processTransaction(_ transaction: Transaction) async {
        // Verify transaction
        guard transaction.revocationDate == nil else {
            // Transaction was revoked (refunded)
            await revokeAccess(for: transaction)
            return
        }
        
        // Handle based on product type
        switch transaction.productType {
        case .consumable:
            await processConsumable(transaction)
            
        case .nonConsumable:
            await processNonConsumable(transaction)
            
        case .autoRenewable:
            await processSubscription(transaction)
            
        case .nonRenewable:
            await processNonRenewableSubscription(transaction)
            
        @unknown default:
            break
        }
    }
    
    private func processConsumable(_ transaction: Transaction) async {
        // Add currency/credits to user account
        let amount = consumableAmount(for: transaction.productID)
        await CurrencyManager.shared.addCredits(amount)
    }
    
    private func processNonConsumable(_ transaction: Transaction) async {
        // Permanently unlock feature
        await FeatureManager.shared.unlock(transaction.productID)
    }
    
    private func processSubscription(_ transaction: Transaction) async {
        // Grant subscription access
        let tier = subscriptionTier(for: transaction.productID)
        await SubscriptionManager.shared.activate(tier: tier, until: transaction.expirationDate)
    }
    
    private func processNonRenewableSubscription(_ transaction: Transaction) async {
        // Grant time-limited access
        let duration = subscriptionDuration(for: transaction.productID)
        let expiration = transaction.purchaseDate.addingTimeInterval(duration)
        await SubscriptionManager.shared.activate(tier: .basic, until: expiration)
    }
    
    private func revokeAccess(for transaction: Transaction) async {
        switch transaction.productType {
        case .consumable:
            // Usually don't revoke consumables
            break
        case .nonConsumable:
            await FeatureManager.shared.revoke(transaction.productID)
        case .autoRenewable, .nonRenewable:
            await SubscriptionManager.shared.deactivate()
        @unknown default:
            break
        }
    }
}
```

### Receipt Validation

```swift
// ✅ iOS 26 - Server-side validation with App Store Server API
struct ReceiptValidator {
    let serverURL: URL
    
    func validateWithServer() async throws -> ValidationResult {
        // Get app transaction for on-device verification
        guard let appTransaction = try? await AppTransaction.shared else {
            throw ValidationError.noAppTransaction
        }
        
        // Get signed transaction for server
        let signedTransactions = try await getSignedTransactions()
        
        // Send to your server
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ValidationPayload(
            transactions: signedTransactions,
            bundleId: Bundle.main.bundleIdentifier ?? "",
            environment: appTransaction.verificationResult.jwsRepresentation
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ValidationResult.self, from: data)
    }
    
    private func getSignedTransactions() async throws -> [String] {
        var transactions: [String] = []
        
        for await result in Transaction.currentEntitlements {
            transactions.append(result.jwsRepresentation)
        }
        
        return transactions
    }
}
```

---

## Testing

### StoreKit Testing in Xcode

```swift
// ✅ iOS 26 - StoreKit Testing support
#if DEBUG
import StoreKitTest

class StoreKitTestObserver {
    var testSession: SKTestSession?
    
    func setupTestEnvironment() throws {
        testSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        testSession?.disableDialogs = true
        testSession?.clearTransactions()
    }
    
    func simulatePurchase(productID: String) async throws {
        guard let session = testSession else { return }
        
        try await session.buyProduct(identifier: productID)
    }
    
    func simulateAskToBuy(productID: String) async throws {
        guard let session = testSession else { return }
        
        session.askToBuyEnabled = true
        try await session.buyProduct(identifier: productID)
    }
    
    func simulateSubscriptionRenewal(productID: String) async throws {
        guard let session = testSession else { return }
        
        try session.forceRenewalOfSubscription(identifier: productID)
    }
    
    func simulateRefund(transactionID: UInt64) async throws {
        guard let session = testSession else { return }
        
        try session.refundTransaction(identifier: transactionID)
    }
}
#endif
```

### Unit Tests

```swift
import Testing
@testable import MyApp

@Suite("StoreKit Tests")
struct StoreKitTests {
    
    @Test("Load products successfully")
    func testLoadProducts() async throws {
        let store = StoreManager()
        try await store.loadProducts()
        
        #expect(!store.products.isEmpty)
        #expect(store.monthlySubscription != nil)
    }
    
    @Test("Purchase flow completes")
    func testPurchaseFlow() async throws {
        let purchaseManager = PurchaseManager()
        let store = StoreManager()
        
        try await store.loadProducts()
        guard let product = store.monthlySubscription else {
            Issue.record("No monthly subscription product")
            return
        }
        
        let transaction = try await purchaseManager.purchase(product)
        #expect(transaction != nil)
    }
    
    @Test("Subscription status is accurate")
    func testSubscriptionStatus() async throws {
        let statusManager = SubscriptionStatusManager()
        let status = try await statusManager.checkSubscriptionStatus()
        
        // In test environment, should be not subscribed
        #expect(status == .notSubscribed)
    }
}
```

---

## Migration Checklist

- [ ] Replace SKProductsRequest with Product.products(for:)
- [ ] Replace SKPaymentQueue with Product.purchase()
- [ ] Implement Transaction.updates listener
- [ ] Update receipt validation to use JWS
- [ ] Add StoreKit Configuration for testing
- [ ] Implement offer code redemption UI
- [ ] Add refund request support
- [ ] Update subscription management UI
- [ ] Test all purchase scenarios
- [ ] Verify server-side validation works

---

## Related Documentation

- [App Intents Migration](./app-intents.md)
- [Swift 6 Migration](../swift6/migration.md)
- [Complete Checklist](../checklist/complete-guide.md)
- [Apple StoreKit Documentation](https://developer.apple.com/documentation/storekit)
