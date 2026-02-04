<p align="center">
  <img src="Assets/logo.png" alt="iOS 26 Migration Guide" width="200"/>
</p>

<h1 align="center">iOS 26 Migration Guide</h1>

<p align="center">
  <strong>📖 The definitive iOS 25 → iOS 26 migration guide with Liquid Glass</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-26-blue.svg" alt="iOS 26"/>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"/>
</p>

---

## What's New in iOS 26

| Feature | Description |
|---------|-------------|
| 🧊 **Liquid Glass** | New UI paradigm |
| 🤖 **Foundation Models** | On-device LLM |
| 📱 **App Intents 2.0** | Enhanced Shortcuts |
| 🔊 **Audio 2.0** | Spatial audio improvements |
| 📸 **Vision 2.0** | Enhanced image analysis |

## Migration Checklist

- [ ] Update to Xcode 18
- [ ] Set deployment target to iOS 26
- [ ] Adopt Liquid Glass design
- [ ] Update deprecated APIs
- [ ] Test on new simulators
- [ ] Submit to TestFlight

## Liquid Glass Migration

```swift
// Before (iOS 25)
.background(.ultraThinMaterial)

// After (iOS 26)
.glassBackground()

// With options
.glassBackground(
    style: .frosted,
    opacity: 0.3
)
```

## Foundation Models

```swift
import FoundationModels

let model = try await LanguageModel.default

let response = try await model.generate(
    prompt: "Summarize this text: \(text)",
    maxTokens: 100
)
```

## Deprecated APIs

| Deprecated | Replacement |
|------------|-------------|
| `UIBlurEffect` | `LiquidGlass` |
| `NavigationView` | `NavigationStack` |
| `AsyncImage` | `CachedAsyncImage` |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/iOS26-Migration-Guide&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/iOS26-Migration-Guide&type=Date" />
 </picture>
</a>
