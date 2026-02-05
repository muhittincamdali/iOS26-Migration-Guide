# HealthKit Migration for iOS 26

> Back to [main guide](../../README.md)

Complete guide for migrating HealthKit integrations to iOS 26, including the new Medications API.

---

## Table of Contents

- [What's New](#whats-new)
- [Medications API](#medications-api)
- [Workout API Updates](#workout-api-updates)
- [Background Delivery](#background-delivery)
- [Data Types](#data-types)
- [Privacy Changes](#privacy-changes)
- [Best Practices](#best-practices)

---

## What's New

iOS 26 HealthKit enhancements:

| Feature | Description | Impact |
|---------|-------------|--------|
| **Medications API** | Read user medications and doses | High |
| **Workout Sessions on iOS** | Run workout sessions on iPhone | High |
| **New Data Types** | Additional health metrics | Medium |
| **Improved Queries** | Better predicate support | Medium |
| **Enhanced Authorization** | Granular permissions | Medium |
| **Background Updates** | More reliable delivery | Medium |

---

## Medications API

### Reading Medications

```swift
import HealthKit

// ✅ iOS 26 - New Medications API
class MedicationsManager {
    let healthStore = HKHealthStore()
    
    // Request authorization
    func requestMedicationsAccess() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        // New medication types
        let medicationTypes: Set<HKSampleType> = [
            HKSampleType.medicationType,
            HKSampleType.medicationDoseEventType
        ]
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: medicationTypes
        )
    }
    
    // Fetch all medications
    func fetchMedications() async throws -> [HKMedication] {
        let query = HKMedicationQuery(healthStore: healthStore)
        return try await query.medications()
    }
    
    // Fetch medication doses
    func fetchDoses(for medication: HKMedication, in dateRange: DateInterval) async throws -> [HKMedicationDoseEvent] {
        let predicate = HKQuery.predicateForSamples(
            withStart: dateRange.start,
            end: dateRange.end,
            options: .strictStartDate
        )
        
        let query = HKMedicationDoseEventQuery(
            medication: medication,
            predicate: predicate,
            healthStore: healthStore
        )
        
        return try await query.doseEvents()
    }
}

// Using medications data
struct MedicationListView: View {
    @State private var medications: [HKMedication] = []
    private let manager = MedicationsManager()
    
    var body: some View {
        List(medications, id: \.uuid) { medication in
            MedicationRow(medication: medication)
        }
        .task {
            do {
                try await manager.requestMedicationsAccess()
                medications = try await manager.fetchMedications()
            } catch {
                print("Failed to load medications: \(error)")
            }
        }
    }
}

struct MedicationRow: View {
    let medication: HKMedication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medication.name)
                .font(.headline)
            
            if let dosage = medication.dosage {
                Text("\(dosage.value) \(dosage.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if let schedule = medication.schedule {
                Text(schedule.description)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Medication Reminders Integration

```swift
// ✅ iOS 26 - Integrate with medication schedules
class MedicationReminderService {
    let healthStore = HKHealthStore()
    
    func setupReminders() async throws {
        let medications = try await fetchMedications()
        
        for medication in medications {
            guard let schedule = medication.schedule else { continue }
            
            for scheduledTime in schedule.scheduledTimes {
                await scheduleNotification(
                    for: medication,
                    at: scheduledTime
                )
            }
        }
    }
    
    private func scheduleNotification(for medication: HKMedication, at time: DateComponents) async {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name)"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_REMINDER"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: time,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "medication-\(medication.uuid)",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
}
```

---

## Workout API Updates

### Workout Sessions on iPhone

```swift
// ✅ iOS 26 - Run workout sessions directly on iPhone
import HealthKit

class WorkoutSessionManager: NSObject {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    func startWorkout(type: HKWorkoutActivityType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        configuration.locationType = .outdoor
        
        // iOS 26 - Create session on iPhone
        session = try HKWorkoutSession(
            healthStore: healthStore,
            configuration: configuration
        )
        
        builder = session?.associatedWorkoutBuilder()
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
        
        // Start session and builder
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
    }
    
    func pauseWorkout() {
        session?.pause()
    }
    
    func resumeWorkout() {
        session?.resume()
    }
    
    func endWorkout() async throws {
        session?.end()
        
        guard let builder = builder else { return }
        
        try await builder.endCollection(at: Date())
        
        let workout = try await builder.finishWorkout()
        print("Workout saved: \(workout.uuid)")
    }
}

extension WorkoutSessionManager: HKWorkoutSessionDelegate {
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        // Handle state changes
        print("Workout state: \(toState)")
    }
    
    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        print("Workout error: \(error)")
    }
}

extension WorkoutSessionManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        // Handle collected data
        for type in collectedTypes {
            if let quantityType = type as? HKQuantityType {
                let statistics = workoutBuilder.statistics(for: quantityType)
                // Process statistics
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
}
```

### Live Activity Integration

```swift
// ✅ iOS 26 - Workout Live Activity
import ActivityKit

struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var duration: TimeInterval
        var heartRate: Double
        var calories: Double
        var distance: Double
    }
    
    var workoutType: String
    var startTime: Date
}

class WorkoutLiveActivityManager {
    var activity: Activity<WorkoutActivityAttributes>?
    
    func startLiveActivity(workoutType: String) async throws {
        let attributes = WorkoutActivityAttributes(
            workoutType: workoutType,
            startTime: Date()
        )
        
        let initialState = WorkoutActivityAttributes.ContentState(
            duration: 0,
            heartRate: 0,
            calories: 0,
            distance: 0
        )
        
        activity = try Activity.request(
            attributes: attributes,
            content: .init(state: initialState, staleDate: nil)
        )
    }
    
    func updateActivity(state: WorkoutActivityAttributes.ContentState) async {
        await activity?.update(.init(state: state, staleDate: nil))
    }
    
    func endActivity(finalState: WorkoutActivityAttributes.ContentState) async {
        await activity?.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .default
        )
    }
}
```

---

## Background Delivery

### Enhanced Background Updates

```swift
// ✅ iOS 26 - Improved background delivery
class HealthKitBackgroundManager {
    let healthStore = HKHealthStore()
    
    func enableBackgroundDelivery() async throws {
        // Heart rate
        try await enableDelivery(for: HKQuantityType(.heartRate), frequency: .immediate)
        
        // Steps
        try await enableDelivery(for: HKQuantityType(.stepCount), frequency: .hourly)
        
        // Sleep
        try await enableDelivery(for: HKCategoryType(.sleepAnalysis), frequency: .immediate)
        
        // Medications (iOS 26)
        try await enableDelivery(for: HKSampleType.medicationDoseEventType, frequency: .immediate)
    }
    
    private func enableDelivery(for type: HKSampleType, frequency: HKUpdateFrequency) async throws {
        try await healthStore.enableBackgroundDelivery(for: type, frequency: frequency)
    }
    
    func handleBackgroundUpdate(for type: HKSampleType) async {
        switch type {
        case HKQuantityType(.heartRate):
            await processHeartRateUpdate()
        case HKQuantityType(.stepCount):
            await processStepUpdate()
        case HKCategoryType(.sleepAnalysis):
            await processSleepUpdate()
        case HKSampleType.medicationDoseEventType:
            await processMedicationDoseUpdate()
        default:
            break
        }
    }
}

// AppDelegate integration
class AppDelegate: NSObject, UIApplicationDelegate {
    let backgroundManager = HealthKitBackgroundManager()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Task {
            try? await backgroundManager.enableBackgroundDelivery()
        }
        return true
    }
}
```

### Observer Queries

```swift
// ✅ iOS 26 - Async observer queries
class HealthObserver {
    let healthStore = HKHealthStore()
    private var observerQueries: [HKObserverQuery] = []
    
    func observeHeartRate() async {
        let heartRateType = HKQuantityType(.heartRate)
        
        // iOS 26 - Async handler
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] query, completionHandler, error in
            Task {
                await self?.handleHeartRateUpdate()
                completionHandler()
            }
        }
        
        healthStore.execute(query)
        observerQueries.append(query)
    }
    
    private func handleHeartRateUpdate() async {
        // Fetch recent heart rate samples
        let heartRateType = HKQuantityType(.heartRate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 10,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
                }
            }
            healthStore.execute(query)
        }
        
        // Process samples
        if let latestSample = samples?.first {
            let heartRate = latestSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            await updateUI(heartRate: heartRate)
        }
    }
    
    @MainActor
    private func updateUI(heartRate: Double) {
        // Update UI
    }
    
    func stopObserving() {
        for query in observerQueries {
            healthStore.stop(query)
        }
        observerQueries.removeAll()
    }
}
```

---

## Data Types

### New iOS 26 Data Types

```swift
// ✅ iOS 26 - New health data types
extension HKQuantityType {
    // Cycling
    static let cyclingSpeed = HKQuantityType(.cyclingSpeed)
    static let cyclingCadence = HKQuantityType(.cyclingCadence)
    static let cyclingPower = HKQuantityType(.cyclingPower)
    
    // Swimming
    static let swimmingStrokeCount = HKQuantityType(.swimmingStrokeCount)
    
    // Mental Health
    static let timeInDaylight = HKQuantityType(.timeInDaylight)
}

extension HKCategoryType {
    // Sleep
    static let sleepAnalysis = HKCategoryType(.sleepAnalysis)
}

// Request authorization for new types
func requestNewTypesAuthorization() async throws {
    let typesToRead: Set<HKSampleType> = [
        HKQuantityType(.cyclingSpeed),
        HKQuantityType(.cyclingCadence),
        HKQuantityType(.cyclingPower),
        HKQuantityType(.swimmingStrokeCount),
        HKQuantityType(.timeInDaylight),
        HKSampleType.medicationType,
        HKSampleType.medicationDoseEventType
    ]
    
    try await healthStore.requestAuthorization(
        toShare: [],
        read: typesToRead
    )
}
```

### Characteristic Types

```swift
// ✅ iOS 26 - Read user characteristics
func readUserCharacteristics() throws {
    // Biological sex
    let biologicalSex = try healthStore.biologicalSex().biologicalSex
    
    // Blood type
    let bloodType = try healthStore.bloodType().bloodType
    
    // Date of birth
    let dateOfBirth = try healthStore.dateOfBirthComponents()
    
    // Fitzpatrick skin type
    let skinType = try healthStore.fitzpatrickSkinType().skinType
    
    // Wheelchair use
    let wheelchairUse = try healthStore.wheelchairUse().wheelchairUse
    
    // iOS 26 - New characteristics
    let activityMoveMode = try healthStore.activityMoveMode().activityMoveMode
}
```

---

## Privacy Changes

### Granular Authorization

```swift
// ✅ iOS 26 - More granular authorization
class HealthKitAuthorizationManager {
    let healthStore = HKHealthStore()
    
    // Request only what you need
    func requestActivityAuthorization() async throws {
        let activityTypes: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned)
        ]
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: activityTypes
        )
    }
    
    func requestHeartAuthorization() async throws {
        let heartTypes: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.restingHeartRate)
        ]
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: heartTypes
        )
    }
    
    func requestMedicationsAuthorization() async throws {
        let medicationTypes: Set<HKSampleType> = [
            HKSampleType.medicationType,
            HKSampleType.medicationDoseEventType
        ]
        
        try await healthStore.requestAuthorization(
            toShare: [],
            read: medicationTypes
        )
    }
    
    // Check authorization status
    func checkAuthorizationStatus(for type: HKSampleType) -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: type)
    }
    
    // iOS 26 - Check if clinical records are available
    func checkClinicalRecordsAvailability() async -> Bool {
        await healthStore.supportsHealthRecords()
    }
}
```

### Privacy Manifest Requirements

```xml
<!-- PrivacyInfo.xcprivacy -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryHealthKit</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>1234.1</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeHealth</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## Best Practices

### 1. Request Minimum Required Access

```swift
// Good: Request only what you need
func requestMinimalAccess() async throws {
    let typesNeeded: Set<HKSampleType> = [
        HKQuantityType(.stepCount)
    ]
    
    try await healthStore.requestAuthorization(
        toShare: [],
        read: typesNeeded
    )
}

// Avoid: Requesting everything
func requestEverything() async throws {
    // Don't do this - bad for privacy and user trust
    let allTypes: Set<HKSampleType> = [
        // ... every possible type
    ]
}
```

### 2. Handle Authorization Gracefully

```swift
struct HealthDashboardView: View {
    @State private var authorizationStatus: AuthStatus = .unknown
    @State private var healthData: HealthData?
    
    var body: some View {
        Group {
            switch authorizationStatus {
            case .unknown:
                ProgressView()
                
            case .denied:
                ContentUnavailableView(
                    "Health Access Required",
                    systemImage: "heart.slash",
                    description: Text("Enable Health access in Settings to see your data")
                )
                
            case .authorized:
                if let data = healthData {
                    HealthDataView(data: data)
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            await checkAuthorization()
        }
    }
    
    private func checkAuthorization() async {
        // Check and request authorization
    }
}
```

### 3. Use Efficient Queries

```swift
// Good: Anchored queries for incremental updates
func setupAnchoredQuery() {
    let anchor = UserDefaults.standard.data(forKey: "healthKitAnchor")
        .flatMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: $0) }
    
    let query = HKAnchoredObjectQuery(
        type: HKQuantityType(.stepCount),
        predicate: nil,
        anchor: anchor,
        limit: HKObjectQueryNoLimit
    ) { query, samples, deletedObjects, newAnchor, error in
        // Process only new/updated samples
        
        // Save anchor for next query
        if let newAnchor = newAnchor,
           let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: newAnchor, requiringSecureCoding: true) {
            UserDefaults.standard.set(anchorData, forKey: "healthKitAnchor")
        }
    }
    
    healthStore.execute(query)
}

// Avoid: Fetching all historical data repeatedly
func fetchAllData() {
    // This is inefficient for incremental updates
}
```

---

## Migration Checklist

- [ ] Update authorization requests for new data types
- [ ] Implement Medications API if needed
- [ ] Migrate workout tracking to iPhone sessions
- [ ] Update background delivery handlers
- [ ] Add Privacy Manifest entries
- [ ] Test authorization flows
- [ ] Handle denied authorization gracefully
- [ ] Optimize queries with anchors
- [ ] Update unit tests

---

## Related Documentation

- [App Intents Migration](./app-intents.md)
- [Swift 6 Migration](../swift6/migration.md)
- [Complete Checklist](../checklist/complete-guide.md)
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
