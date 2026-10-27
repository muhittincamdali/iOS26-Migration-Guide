<!-- i18n-source: README.md@b6354fa4fccc4cdcfbf0e15989f5e4db1e94192b status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

iOS uygulamasını iOS 26 ve iOS 27 SDK'larına taşımak için bir komut satırı aracı, bir Swift kütüphanesi ve bir rehber seti. `migration-scan`, Swift kaynaklarınızı, Info.plist dosyalarınızı ve Xcode derleme ayarlarınızı okur; bu SDK'ların hangi öğeleri kullanımdan kaldırdığını, yok saydığını ya da reddettiğini listeler. Her bulguda yerine ne yazmanız gerektiği ve Apple'ın ilgili dokümantasyonuna bir bağlantı bulunur. Listeyi Xcode göstermeden önce elde etmek isteyen uygulama geliştiricileri için hazırlandı. Xcode'un hiç bildirmediği değişiklikleri de yakalar: sahne (scene) manifesti olmayan bir UIKit uygulaması iOS 27 SDK'sıyla derlendiğinde açılmaz ve derleyici bu konuda tek kelime etmez.

## Öne çıkanlar

- **Uygulamanın açılmasını engelleyen sorunları bulur** — sahne manifesti olmayan ya da manifesti hiçbir sahne yapılandırması belirtmeyen bir UIKit app delegate'i, Apple'ın TN3187 notunu izleyerek hata olarak bildirilir.
- **Derleyicinin uyarmadığı sorunları bulur** — uygulama sahneleri kullanmaya başlayınca UIKit'in artık çağırmadığı app delegate metotları, iOS 27'nin yok saydığı `UIDesignRequiresCompatibility` ve yalnızca gelecek bir sürümde kullanımdan kalkan SwiftUI API'leri.
- **Her kural SDK'ya karşı doğrulanmıştır** — 42 kuralın her biri, dayandığı bildirimi iOS 27.1 SDK başlıklarında ya da Swift arayüzlerinde gösterir (`migration-scan --explain <rule>`).
- **Metni değil kodu okur** — yorumlar ve string'ler hiçbir zaman eşleşmez, string interpolation içindeki kod eşleşir; çağrılar ve bildirimler argüman etiketlerine göre eşleştirilir.
- **Baktığınız her yer için çıktı** — düz metin, Xcode sorunları, GitHub pull request açıklamaları, kod taraması için SARIF ve JSON. Raporlar kaynak kodu asla kopyalamaz.
- **Derlenen kodlu rehberler** — örnek kod parçaları, CI'ın derleyip test ettiği MigrationLab örnek uygulamasından gelen sahne yaşam döngüsü ve Liquid Glass rehberleri.

## Hızlı başlangıç

**1. Tarayıcıyı edinin**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Uygulamanızı tarayın**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Bildirilenleri düzeltin**

Her bulgu nerede, neden ve yerine ne yazılacağını söyler. [Test fixture'larındaki](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp) eski uygulama için bulunan 21 bulgudan ikisi:

```text
LegacyApp/LegacyApp/AppDelegate.swift:3:1: error: The app does not adopt the scene life cycle [scene-manifest-missing]
    This UIKit app has no UIApplicationSceneManifest. Built with the iOS 27 SDK, an app without the scene life cycle does not launch.
    Fix: Add a UIApplicationSceneManifest with a window scene configuration to Info.plist, add a UIWindowSceneDelegate and create the window in scene(_:willConnectTo:options:).
    See: https://developer.apple.com/documentation/technotes/tn3187-migrating-to-the-uikit-scene-based-life-cycle
…
LegacyApp/LegacyApp/AppDelegate.swift:11:43: warning: UIScreen.main [uiscreen-main]
    With scenes and external displays an app can be on more than one screen, so there is no single main screen; deprecated in iOS 26.0.
    Fix: Use view.window?.windowScene?.screen, or a trait such as traitCollection.displayScale for the scale.
    See: https://developer.apple.com/documentation/uikit/uiscreen/main
…
3 errors, 14 warnings, 4 info in 4 files.
```

Hatalarla başlayın. [Sahne yaşam döngüsü rehberi](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle), en yaygın olanı adım adım anlatır.

## Kurulum

### Komut satırı

Hızlı başlangıçtaki gibi bir klondan derleyin; komut `.build/release/migration-scan` olur. Klon olmadan çalıştırmak için paketi başka bir paketin bağımlılıklarına ekleyin ve `swift run migration-scan` komutunu çalıştırın.

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS26-Migration-Guide.git", from: "2.0.0")
],
targets: [
    .target(name: "YourTool", dependencies: [
        .product(name: "MigrationScanner", package: "iOS26-Migration-Guide")
    ])
]
```

## Kullanım

### Neyin raporlanacağını seçin

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

Bir bulgu `--fail-on` eşiğine ulaştığında çıkış durumu 1 olur (varsayılan `error`; `warning`, `info` ya da `never` de verilebilir). Komut satırı hatalıysa 2, diğer durumlarda 0 döner.

### Bulguları Xcode'da gösterin

Bir Run Script derleme aşaması ekleyin; Xcode her bulguyu sorun gezgininde listeler:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

O hedef için `ENABLE_USER_SCRIPT_SANDBOXING` ayarını kapatın, yoksa betik kaynakları okuyamaz.

### Pull request'lere açıklama ekleyin

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif`, bunun yerine GitHub kod taraması için bir rapor yazar; [CI rehberine](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) bakın.

### Bir bulguyu bilerek bırakın

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Kodun ardındaki yorum kendi satırı için, tek başına duran yorum bir sonraki satır için geçerlidir; `// migration-scan:ignore-file <rules>` ise dosyanın tamamını kapsar. Bilinmeyen bir kuralı adlandıran yorum, sessizce hiçbir şeyi bastırmamak yerine raporlanır.

### Swift'ten tarayın

```swift
func scanProject(at folder: URL) -> String {
    let report = ProjectScanner().scan(paths: [folder])
    return ReportFormatter.format(report, as: .text)
}
```

```swift
func blockingFindings(in folder: URL) -> [Finding] {
    var configuration = ScanConfiguration(minimumSeverity: .warning)
    configuration.excludedDirectoryNames.insert("Generated")
    let report = ProjectScanner(configuration: configuration).scan(paths: [folder])
    return report.findings.filter { $0.severity == .error }
}
```

`scan(source:)` tek bir kaynak metnini denetler; örnek uygulama siz yazarken kodu bu şekilde yeniden tarar:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Sahne yaşam döngüsüne geçin

Taşımanın özü, örnek uygulamanın sahne delegate'inden: pencere pencere sahnesine aittir ve uygulamayı başlatan URL bağlantı seçeneklerinde gelir.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Demo

[MigrationLab](Examples/MigrationLab), SwiftUI ekranları olan, sahne tabanlı bir UIKit uygulamasıdır: canlı bulgular gösteren bir kaynak düzenleyici, kural kataloğu, özel bir denetimde Liquid Glass ve pencere sahnesinin kendisi hakkında bildirdikleri. `Examples/MigrationLab/MigrationLab.xcodeproj` dosyasını açın ve bir iOS 26 simülatöründe çalıştırın. `migrationlab://rule/<rule-id>` bir kuralı açar.

| Tarayıcı | Kurallar | Liquid Glass | Sahne |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="Eski bir app delegate ve bulgularının göründüğü tarayıcı ekranı" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="42 kuralın aranabilir listesi" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Mavi bir gradyan üzerinde, glass effect container içinde cam düğmeler" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="Pencere sahnesinin rolü, pencereleri, yönelimi ve ekran ölçeği" width="200"></picture> |

Ekran görüntüleri çalışan uygulamadan alınmıştır; `scripts/capture-example-screens.sh` bunları yeniden çeker.

## Dokümantasyon

API başvuru belgeleri ve makaleler:

- [GitHub Pages üzerinde MigrationScanner](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — API başvurusu
- [Başlarken](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Kural başvurusu](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — 42 kuralın tamamı ve düzeltmeleri

## Rehberler

- [Sahne yaşam döngüsüne geçiş](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifest, sahne delegate'i, taşınan metotlar ve `UIScreen.main` yerine kullanılacaklar
- [Liquid Glass'a geçiş](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — Liquid Glass'ı devre dışı bırakmayı bırakın, özel arka planları kaldırın, yeniden adlandırılan API'ler, özel denetimlerde cam
- [Xcode ve CI'da çalıştırma](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — derleme aşaması, pull request açıklamaları, kod taraması, JSON

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Araç zinciri | Swift 6.2 (Xcode 26) |

## Mimari

- `Lexer`, bir Swift dosyasını token'lara ve yorumlara ayırır; string içerikleri ve yorumlar hiçbir zaman token olmaz, interpolation içindeki kod olur.
- `BracketIndex` ve `TokenIndex`, tanımlayıcıları, parantez çiftlerini, argüman etiketlerini ve closure parametrelerini tek geçişte indeksler; böylece her eşleştirici dosya boyutuyla doğrusal çalışır.
- `RuleCatalog` kuralları tutar; her kuralın bir eşleştiricisi (token dizisi, üye erişimi, argüman etiketli çağrı ya da bildirim veya bir proje denetimi), bir önem derecesi ve SDK kanıtı vardır.
- `ProjectFacts`, proje kuralları için uygulama giriş noktalarını, Info.plist değerlerini ve derleme ayarlarını toplar. `PropertyListGuard`, sistem ayrıştırıcısı okumadan önce çok derin iç içe geçmiş, döngüsel ya da bozuk property list'leri reddeder.
- `ProjectScanner` dosyalarda boyut ve sayı sınırlarıyla dolaşır, sembolik bağlantıları asla izlemez; `ReportFormatter` beş biçimi yazar ve yollardaki kontrol karakterlerini kaçırır.
- `MigrationScanCLI` komut satırını ayrıştırıp doğrular; `migration-scan` çalıştırılabilir dosyası yalnızca ona iletir.

### Bilinen sınırlamalar

- Tarayıcı kaynak metnini okur; tür denetimi yapmaz. `uiapplication-key-window` gibi bir kural `UIApplication.shared.keyWindow` ifadesiyle eşleşir, başka bir değişken üzerinden erişilen `keyWindow` ile eşleşmez.
- Proje kuralları, taranan klasör başına tek bir uygulama olduğunu varsayar: klasörün herhangi bir yerindeki Info.plist dosyaları ve derleme ayarları orada bulunan uygulamaya sayılır.
- Yerine konacak kodu önerir, kodu asla yeniden yazmaz.

## Yol haritası

Yeni kurallar yeni SDK sürümlerini izler; her biri dayandığı SDK bildirimiyle, raporlaması gereken bir örnekle ve dokunmaması gereken bir örnekle eklenir. İstekler ve raporlar [issue'lara](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues) gider.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](CONTRIBUTING.md) ve [davranış kurallarını](CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
