# Foundation Models & Core ML Migration for iOS 26

> Back to [main guide](../../README.md)

Complete guide for adopting Apple's on-device Foundation Models and Core ML enhancements in iOS 26.

---

## Table of Contents

- [What's New](#whats-new)
- [Foundation Models Framework](#foundation-models-framework)
- [Core ML Updates](#core-ml-updates)
- [Speech Recognition](#speech-recognition)
- [Natural Language](#natural-language)
- [Vision Framework](#vision-framework)
- [Best Practices](#best-practices)

---

## What's New

iOS 26 AI/ML capabilities:

| Feature | Description | Impact |
|---------|-------------|--------|
| **Foundation Models** | On-device LLM access | High |
| **SpeechAnalyzer** | Advanced speech analysis | High |
| **Federated Learning** | Privacy-preserving ML | Medium |
| **MLX Integration** | Apple Silicon optimization | Medium |
| **Vision 2.0** | Enhanced image analysis | Medium |
| **Core ML 8** | Performance improvements | Medium |

---

## Foundation Models Framework

### Basic Text Generation

```swift
import FoundationModels

// ✅ iOS 26 - On-device language model
@available(iOS 26.0, *)
class AIAssistant {
    private let model: LanguageModel
    
    init() async throws {
        // Initialize the default on-device model
        model = try await LanguageModel.default
    }
    
    func generateResponse(to prompt: String) async throws -> String {
        let response = try await model.generate(
            prompt: prompt,
            maxTokens: 500
        )
        return response.text
    }
    
    // With system prompt
    func chat(userMessage: String, context: String) async throws -> String {
        let response = try await model.generate(
            prompt: userMessage,
            systemPrompt: context,
            temperature: 0.7,
            topP: 0.9
        )
        return response.text
    }
}

// Usage
let assistant = try await AIAssistant()
let response = try await assistant.generateResponse(to: "Summarize this email: \(emailContent)")
```

### Streaming Responses

```swift
// ✅ iOS 26 - Stream text generation
@available(iOS 26.0, *)
struct StreamingChatView: View {
    @State private var userInput = ""
    @State private var responseText = ""
    @State private var isGenerating = false
    
    private let model: LanguageModel
    
    var body: some View {
        VStack {
            ScrollView {
                Text(responseText)
                    .padding()
            }
            
            HStack {
                TextField("Ask anything...", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: generateResponse) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(isGenerating || userInput.isEmpty)
            }
            .padding()
        }
    }
    
    func generateResponse() {
        let prompt = userInput
        userInput = ""
        responseText = ""
        isGenerating = true
        
        Task {
            do {
                for try await chunk in model.stream(prompt: prompt) {
                    await MainActor.run {
                        responseText += chunk.text
                    }
                }
            } catch {
                await MainActor.run {
                    responseText = "Error: \(error.localizedDescription)"
                }
            }
            await MainActor.run {
                isGenerating = false
            }
        }
    }
}
```

### Structured Output

```swift
// ✅ iOS 26 - Generate structured data
@available(iOS 26.0, *)
struct ContentAnalyzer {
    let model: LanguageModel
    
    // Define output structure
    struct SentimentAnalysis: Codable {
        let sentiment: String // positive, negative, neutral
        let confidence: Double
        let keywords: [String]
        let summary: String
    }
    
    func analyzeSentiment(text: String) async throws -> SentimentAnalysis {
        // Generate structured output
        let result: SentimentAnalysis = try await model.generate(
            prompt: """
            Analyze the sentiment of the following text.
            Provide a sentiment (positive/negative/neutral), confidence score (0-1),
            key words, and a brief summary.
            
            Text: \(text)
            """,
            outputType: SentimentAnalysis.self
        )
        
        return result
    }
    
    // Recipe extraction example
    struct Recipe: Codable {
        let name: String
        let ingredients: [Ingredient]
        let steps: [String]
        let prepTime: Int // minutes
        let cookTime: Int // minutes
        
        struct Ingredient: Codable {
            let name: String
            let amount: String
            let unit: String
        }
    }
    
    func extractRecipe(from text: String) async throws -> Recipe {
        try await model.generate(
            prompt: "Extract the recipe from this text: \(text)",
            outputType: Recipe.self
        )
    }
}
```

### Text Embeddings

```swift
// ✅ iOS 26 - Generate embeddings for semantic search
@available(iOS 26.0, *)
class SemanticSearchEngine {
    let model: LanguageModel
    var documentEmbeddings: [(id: String, embedding: [Float])] = []
    
    func indexDocuments(_ documents: [(id: String, text: String)]) async throws {
        for document in documents {
            let embedding = try await model.embedding(for: document.text)
            documentEmbeddings.append((document.id, embedding.values))
        }
    }
    
    func search(query: String, topK: Int = 5) async throws -> [String] {
        let queryEmbedding = try await model.embedding(for: query)
        
        // Calculate cosine similarity
        let similarities = documentEmbeddings.map { doc in
            (id: doc.id, similarity: cosineSimilarity(queryEmbedding.values, doc.embedding))
        }
        
        // Return top K results
        return similarities
            .sorted { $0.similarity > $1.similarity }
            .prefix(topK)
            .map { $0.id }
    }
    
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        let dotProduct = zip(a, b).map(*).reduce(0, +)
        let magnitudeA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magnitudeB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitudeA * magnitudeB)
    }
}
```

---

## Core ML Updates

### Model Loading Improvements

```swift
import CoreML

// ✅ iOS 26 - Async model loading with configuration
@available(iOS 26.0, *)
class MLModelManager {
    var model: MLModel?
    
    func loadModel() async throws {
        let configuration = MLModelConfiguration()
        
        // iOS 26 - Enhanced compute units selection
        configuration.computeUnits = .all
        configuration.allowLowPrecisionAccumulationOnGPU = true
        
        // New: Model caching
        configuration.modelCachePolicy = .persistent
        
        // New: Memory optimization
        configuration.memoryManagement = .lowMemory
        
        // Async loading
        model = try await MyModel.load(configuration: configuration)
    }
    
    func predict(input: MyModelInput) async throws -> MyModelOutput {
        guard let model = model else {
            throw MLError.modelNotLoaded
        }
        
        // iOS 26 - Async prediction
        return try await model.prediction(input: input)
    }
}

enum MLError: Error {
    case modelNotLoaded
}
```

### On-Device Training

```swift
// ✅ iOS 26 - Enhanced on-device training
@available(iOS 26.0, *)
class PersonalizedModelTrainer {
    let baseModel: MLModel
    var personalizedModel: MLModel?
    
    func trainOnUserData(samples: [TrainingSample]) async throws {
        // Create update task
        let updateTask = try MLUpdateTask(
            forModelAt: baseModelURL,
            trainingData: createBatchProvider(from: samples),
            configuration: trainingConfiguration
        )
        
        // iOS 26 - Progress tracking
        for await progress in updateTask.progress {
            print("Training progress: \(progress.fractionCompleted)")
        }
        
        // Get updated model
        personalizedModel = try await updateTask.result.model
        
        // Save personalized model
        try await saveModel(personalizedModel!)
    }
    
    private var trainingConfiguration: MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        return config
    }
    
    private func createBatchProvider(from samples: [TrainingSample]) -> MLBatchProvider {
        // Create batch provider from training samples
        let featureProviders = samples.map { sample in
            try! MLDictionaryFeatureProvider(dictionary: [
                "input": MLFeatureValue(multiArray: sample.input),
                "output": MLFeatureValue(multiArray: sample.output)
            ])
        }
        return MLArrayBatchProvider(array: featureProviders)
    }
}
```

### Federated Learning

```swift
// ✅ iOS 26 - Privacy-preserving federated learning
@available(iOS 26.0, *)
class FederatedLearningManager {
    
    func participateInFederatedTraining() async throws {
        // Check eligibility
        guard await FederatedLearning.isEligible() else {
            print("Device not eligible for federated learning")
            return
        }
        
        // Register for federated learning task
        let task = try await FederatedLearning.registerTask(
            identifier: "com.myapp.personalization",
            modelURL: localModelURL,
            trainingDataProvider: UserDataProvider()
        )
        
        // Task runs automatically when conditions are met
        // (device charging, on Wi-Fi, sufficient battery)
        
        // Monitor task status
        for await status in task.statusUpdates {
            switch status {
            case .pending:
                print("Waiting for conditions")
            case .training:
                print("Training in progress")
            case .uploading:
                print("Uploading gradients")
            case .completed:
                print("Federated round completed")
            case .failed(let error):
                print("Failed: \(error)")
            }
        }
    }
}

// User data provider for federated learning
class UserDataProvider: FederatedTrainingDataProvider {
    func trainingData() async throws -> MLBatchProvider {
        // Return local training data
        // Data never leaves device - only gradients are shared
        let samples = await loadLocalUserData()
        return createBatchProvider(from: samples)
    }
}
```

---

## Speech Recognition

### SpeechAnalyzer API

```swift
import Speech

// ✅ iOS 26 - New SpeechAnalyzer API
@available(iOS 26.0, *)
class AdvancedSpeechRecognizer {
    private let analyzer: SpeechAnalyzer
    
    init() async throws {
        analyzer = try await SpeechAnalyzer()
    }
    
    // Real-time transcription with rich metadata
    func startTranscription(from audioStream: AsyncStream<AVAudioPCMBuffer>) async throws {
        for try await result in analyzer.analyze(audioStream) {
            // Transcription text
            let text = result.transcription.formattedString
            
            // Speaker diarization (who said what)
            for segment in result.speakerSegments {
                print("Speaker \(segment.speakerID): \(segment.text)")
                print("  Confidence: \(segment.confidence)")
                print("  Time: \(segment.timeRange)")
            }
            
            // Emotion detection
            if let emotion = result.detectedEmotion {
                print("Detected emotion: \(emotion.primary)")
                print("  Confidence: \(emotion.confidence)")
            }
            
            // Language detection
            if let language = result.detectedLanguage {
                print("Language: \(language.identifier)")
            }
        }
    }
    
    // Offline transcription
    func transcribeFile(at url: URL) async throws -> TranscriptionResult {
        let audioFile = try AVAudioFile(forReading: url)
        return try await analyzer.transcribe(audioFile)
    }
}

// SwiftUI integration
@available(iOS 26.0, *)
struct VoiceNoteView: View {
    @State private var isRecording = false
    @State private var transcription = ""
    @State private var speakers: [SpeakerInfo] = []
    
    private let recognizer = AdvancedSpeechRecognizer()
    
    var body: some View {
        VStack {
            // Transcription display
            ScrollView {
                ForEach(speakers) { speaker in
                    HStack(alignment: .top) {
                        Text("Speaker \(speaker.id):")
                            .fontWeight(.bold)
                        Text(speaker.text)
                    }
                }
            }
            
            // Record button
            Button(action: toggleRecording) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(isRecording ? .red : .blue)
            }
        }
    }
}
```

---

## Natural Language

### Enhanced NL Processing

```swift
import NaturalLanguage

// ✅ iOS 26 - Enhanced Natural Language processing
@available(iOS 26.0, *)
class TextAnalyzer {
    
    func analyzeText(_ text: String) -> TextAnalysis {
        var analysis = TextAnalysis()
        
        // Tokenization
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            tokens.append(String(text[range]))
            return true
        }
        analysis.tokens = tokens
        
        // Named entity recognition
        let tagger = NLTagger(tagSchemes: [.nameType, .sentimentScore])
        tagger.string = text
        
        var entities: [NamedEntity] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if let tag = tag {
                entities.append(NamedEntity(
                    text: String(text[range]),
                    type: tag.rawValue
                ))
            }
            return true
        }
        analysis.entities = entities
        
        // Sentiment analysis
        if let sentiment = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0 {
            analysis.sentimentScore = Double(sentiment.rawValue) ?? 0
        }
        
        // iOS 26 - New: Intent classification
        let intentClassifier = try? NLModel(mlModel: IntentClassifier().model)
        if let intent = intentClassifier?.predictedLabel(for: text) {
            analysis.intent = intent
        }
        
        // iOS 26 - New: Topic classification
        let topicClassifier = try? NLModel(mlModel: TopicClassifier().model)
        if let topic = topicClassifier?.predictedLabel(for: text) {
            analysis.topic = topic
        }
        
        return analysis
    }
    
    struct TextAnalysis {
        var tokens: [String] = []
        var entities: [NamedEntity] = []
        var sentimentScore: Double = 0
        var intent: String?
        var topic: String?
    }
    
    struct NamedEntity {
        let text: String
        let type: String
    }
}
```

### Translation

```swift
// ✅ iOS 26 - Enhanced translation
@available(iOS 26.0, *)
class TranslationService {
    
    func translate(
        _ text: String,
        from sourceLanguage: Locale.Language,
        to targetLanguage: Locale.Language
    ) async throws -> String {
        // Check availability
        let availability = try await TranslationSession.availability(
            from: sourceLanguage,
            to: targetLanguage
        )
        
        switch availability {
        case .available:
            break
        case .downloadRequired:
            // Download language pack
            try await TranslationSession.downloadLanguage(
                from: sourceLanguage,
                to: targetLanguage
            )
        case .unsupported:
            throw TranslationError.unsupportedLanguagePair
        }
        
        // Create session and translate
        let session = try await TranslationSession(
            from: sourceLanguage,
            to: targetLanguage
        )
        
        let result = try await session.translate(text)
        return result.targetText
    }
    
    // Batch translation
    func translateBatch(
        texts: [String],
        from sourceLanguage: Locale.Language,
        to targetLanguage: Locale.Language
    ) async throws -> [String] {
        let session = try await TranslationSession(
            from: sourceLanguage,
            to: targetLanguage
        )
        
        let results = try await session.translate(texts)
        return results.map { $0.targetText }
    }
}

enum TranslationError: Error {
    case unsupportedLanguagePair
}
```

---

## Vision Framework

### Enhanced Image Analysis

```swift
import Vision

// ✅ iOS 26 - Enhanced Vision capabilities
@available(iOS 26.0, *)
class ImageAnalyzer {
    
    func analyzeImage(_ image: CGImage) async throws -> ImageAnalysis {
        var analysis = ImageAnalysis()
        
        // Object detection
        let objectRequest = VNRecognizeObjectsRequest()
        objectRequest.revision = VNRecognizeObjectsRequestRevision2 // iOS 26
        
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([objectRequest])
        
        if let results = objectRequest.results {
            analysis.objects = results.map { observation in
                DetectedObject(
                    label: observation.labels.first?.identifier ?? "Unknown",
                    confidence: observation.confidence,
                    boundingBox: observation.boundingBox
                )
            }
        }
        
        // Text recognition
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.recognitionLanguages = ["en-US", "ja-JP", "zh-Hans"]
        textRequest.automaticallyDetectsLanguage = true // iOS 26
        
        try handler.perform([textRequest])
        
        if let results = textRequest.results {
            analysis.recognizedText = results.compactMap { $0.topCandidates(1).first?.string }
        }
        
        // Face analysis
        let faceRequest = VNDetectFaceExpressionsRequest() // iOS 26
        try handler.perform([faceRequest])
        
        if let results = faceRequest.results {
            analysis.faces = results.map { face in
                FaceAnalysis(
                    boundingBox: face.boundingBox,
                    expression: face.expression?.rawValue,
                    landmarks: face.landmarks
                )
            }
        }
        
        // Scene classification
        let sceneRequest = VNClassifyImageRequest()
        try handler.perform([sceneRequest])
        
        if let results = sceneRequest.results?.prefix(5) {
            analysis.sceneClassifications = results.map {
                ($0.identifier, $0.confidence)
            }
        }
        
        return analysis
    }
    
    struct ImageAnalysis {
        var objects: [DetectedObject] = []
        var recognizedText: [String] = []
        var faces: [FaceAnalysis] = []
        var sceneClassifications: [(String, Float)] = []
    }
    
    struct DetectedObject {
        let label: String
        let confidence: Float
        let boundingBox: CGRect
    }
    
    struct FaceAnalysis {
        let boundingBox: CGRect
        let expression: String?
        let landmarks: VNFaceLandmarks2D?
    }
}
```

### Document Scanner

```swift
// ✅ iOS 26 - Enhanced document scanning
@available(iOS 26.0, *)
class DocumentScanner {
    
    func scanDocument(_ image: CGImage) async throws -> ScannedDocument {
        let handler = VNImageRequestHandler(cgImage: image)
        
        // Detect document boundaries
        let documentRequest = VNDetectDocumentSegmentationRequest()
        try handler.perform([documentRequest])
        
        guard let documentObservation = documentRequest.results?.first else {
            throw ScanError.noDocumentFound
        }
        
        // Perspective correction
        let correctedImage = try await correctPerspective(
            image: image,
            using: documentObservation
        )
        
        // OCR with structure preservation
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        
        // iOS 26 - Preserve document structure
        textRequest.recognizesStructure = true
        
        let correctedHandler = VNImageRequestHandler(cgImage: correctedImage)
        try correctedHandler.perform([textRequest])
        
        var document = ScannedDocument()
        document.image = correctedImage
        
        if let results = textRequest.results {
            // Extract structured content
            for observation in results {
                if let structure = observation.structureInfo { // iOS 26
                    switch structure.type {
                    case .paragraph:
                        document.paragraphs.append(observation.topCandidates(1).first?.string ?? "")
                    case .heading:
                        document.headings.append(observation.topCandidates(1).first?.string ?? "")
                    case .listItem:
                        document.listItems.append(observation.topCandidates(1).first?.string ?? "")
                    case .table:
                        // Handle table extraction
                        break
                    default:
                        break
                    }
                }
            }
        }
        
        return document
    }
    
    struct ScannedDocument {
        var image: CGImage?
        var headings: [String] = []
        var paragraphs: [String] = []
        var listItems: [String] = []
    }
}

enum ScanError: Error {
    case noDocumentFound
}
```

---

## Best Practices

### 1. Check Model Availability

```swift
// Always check if on-device models are available
func checkAIAvailability() async -> Bool {
    if #available(iOS 26.0, *) {
        return await LanguageModel.isAvailable
    }
    return false
}

// Graceful fallback
func generateSummary(_ text: String) async throws -> String {
    if #available(iOS 26.0, *), await LanguageModel.isAvailable {
        let model = try await LanguageModel.default
        return try await model.generate(prompt: "Summarize: \(text)").text
    } else {
        // Fallback to server-based or simple summarization
        return simpleSummarize(text)
    }
}
```

### 2. Handle Resource Constraints

```swift
// Monitor and respect resource constraints
@available(iOS 26.0, *)
class ResourceAwareML {
    func runInference() async throws {
        // Check thermal state
        let thermalState = ProcessInfo.processInfo.thermalState
        
        switch thermalState {
        case .nominal, .fair:
            // Full processing
            try await runFullInference()
        case .serious:
            // Reduced processing
            try await runLightweightInference()
        case .critical:
            // Defer processing
            throw ResourceError.thermalThrottling
        @unknown default:
            try await runLightweightInference()
        }
    }
    
    func checkMemoryPressure() -> Bool {
        // Check available memory before loading large models
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return false }
        
        let usedMemoryMB = info.resident_size / 1024 / 1024
        return usedMemoryMB < 500 // Allow if under 500MB
    }
}

enum ResourceError: Error {
    case thermalThrottling
    case insufficientMemory
}
```

### 3. Privacy-First Design

```swift
// All processing on-device
@available(iOS 26.0, *)
class PrivacyFirstAssistant {
    let model: LanguageModel
    
    func processUserData(_ data: UserData) async throws -> ProcessedResult {
        // Process locally - data never leaves device
        let analysis = try await model.generate(
            prompt: "Analyze this data: \(data.sanitized)",
            systemPrompt: "You are a helpful assistant. Never reference specific personal details."
        )
        
        // Return only sanitized results
        return ProcessedResult(
            insights: analysis.text,
            privacyLevel: .onDeviceOnly
        )
    }
}
```

---

## Migration Checklist

- [ ] Check iOS 26 availability before using Foundation Models
- [ ] Implement graceful fallbacks for older devices
- [ ] Update Core ML model configuration for new options
- [ ] Migrate to SpeechAnalyzer for speech recognition
- [ ] Add structured output support where applicable
- [ ] Implement resource monitoring
- [ ] Test on various device configurations
- [ ] Update privacy documentation

---

## Related Documentation

- [App Intents Migration](./app-intents.md)
- [Swift 6 Migration](../swift6/migration.md)
- [Complete Checklist](../checklist/complete-guide.md)
- [Apple Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [Apple Foundation Models](https://developer.apple.com/documentation/foundationmodels)
