<!-- i18n-source: README.md@160fc1ab707277cda7e31fd2d880426e457f1746 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Ein Kommandozeilenwerkzeug, eine Swift-Bibliothek und eine Reihe von Anleitungen, um eine iOS-App auf die SDKs von iOS 26 und iOS 27 umzustellen. `migration-scan` liest deine Swift-Quellen, Info.plist-Dateien und Xcode-Build-Einstellungen und listet auf, was diese SDKs als veraltet markieren, ignorieren oder ablehnen, jeweils mit dem, was du stattdessen schreiben sollst, und einem Link zur Dokumentation von Apple. Das Werkzeug richtet sich an App-Entwickler, die die Liste haben wollen, bevor Xcode sie anzeigt, oder die Änderungen kennen müssen, die Xcode nie meldet: Eine UIKit-App ohne Scene-Manifest startet nicht, wenn sie mit dem iOS-27-SDK gebaut wird, und der Compiler sagt dazu nichts.

## Highlights

- **Findet, was den Start einer App verhindert** — ein UIKit-App-Delegate ohne Scene-Manifest oder mit einem Manifest, das keine Scene-Konfiguration nennt, wird gemäß Apples TN3187 als Fehler gemeldet.
- **Findet, wovor der Compiler nicht warnt** — App-Delegate-Methoden, die UIKit nicht mehr aufruft, sobald die App Scenes verwendet, `UIDesignRequiresCompatibility`, das iOS 27 ignoriert, und SwiftUI-API, die erst in einer künftigen Version als veraltet gilt.
- **Jede Regel ist gegen das SDK geprüft** — jede der 42 Regeln nennt die Deklaration in den Headern des iOS-27.1-SDKs oder in den Swift-Interfaces, auf der sie beruht (`migration-scan --explain <rule>`).
- **Liest Code, nicht Text** — Kommentare und Strings führen nie zu Treffern, Code in String-Interpolationen schon, und Aufrufe und Deklarationen werden anhand ihrer Argumentlabels erkannt.
- **Ausgabe für jeden Ort, an dem du nachsiehst** — Klartext, Xcode-Issues, Anmerkungen in GitHub-Pull-Requests, SARIF für das Code Scanning und JSON. Berichte kopieren nie Quellcode.
- **Anleitungen mit Code, der baut** — Anleitungen zum Scene-Lebenszyklus und zu Liquid Glass, deren Snippets aus der Beispiel-App MigrationLab stammen, die CI baut und testet.

## Schnellstart

**1. Scanner besorgen**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Deine App scannen**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Beheben, was gemeldet wird**

Jeder Fund sagt, wo, warum und was du stattdessen schreiben sollst. Zwei der 21 Funde für die Legacy-App in [den Test-Fixtures](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp):

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

Beginne mit den Fehlern. Die [Anleitung zum Scene-Lebenszyklus](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) führt Schritt für Schritt durch den häufigsten.

## Installation

### Kommandozeile

Baue das Werkzeug wie im Schnellstart aus einem Klon; der Befehl lautet `.build/release/migration-scan`. Um es ohne Klon auszuführen, füge das Paket den Abhängigkeiten eines anderen Pakets hinzu und rufe `swift run migration-scan` auf.

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

## Verwendung

### Auswählen, was gemeldet wird

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

Der Exit-Status ist 1, wenn ein Fund `--fail-on` erreicht (standardmäßig `error`; möglich sind auch `warning`, `info` oder `never`), 2 bei einer fehlerhaften Kommandozeile und sonst 0.

### Funde in Xcode anzeigen

Füge eine Run-Script-Build-Phase hinzu; Xcode listet dann jeden Fund im Issue-Navigator auf:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Schalte `ENABLE_USER_SCRIPT_SANDBOXING` für dieses Target aus, sonst kann das Skript die Quellen nicht lesen.

### Pull Requests annotieren

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` schreibt stattdessen einen Bericht für das GitHub Code Scanning; siehe die [CI-Anleitung](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Einen Fund bewusst beibehalten

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Ein Kommentar hinter dem Code gilt für dessen Zeile, ein Kommentar in einer eigenen Zeile für die nächste Zeile und `// migration-scan:ignore-file <rules>` für die ganze Datei. Ein Kommentar, der eine unbekannte Regel nennt, wird gemeldet, statt stillschweigend nichts zu unterdrücken.

### Aus Swift scannen

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

`scan(source:)` prüft einen einzelnen Quelltext; so scannt die Beispiel-App neu, während du tippst:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Den Scene-Lebenszyklus übernehmen

Der Kern der Umstellung, aus dem Scene-Delegate der Beispiel-App: Das Fenster gehört zur Window-Scene, und die URL, mit der die App gestartet wurde, kommt in den Verbindungsoptionen an.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Demo

[MigrationLab](Examples/MigrationLab) ist eine Scene-basierte UIKit-App mit SwiftUI-Bildschirmen: ein Quelltext-Editor mit Live-Funden, der Regelkatalog, Liquid Glass auf einem eigenen Steuerelement und das, was die Window-Scene über sich selbst meldet. Öffne `Examples/MigrationLab/MigrationLab.xcodeproj` und starte die App in einem iOS-26-Simulator. `migrationlab://rule/<rule-id>` öffnet eine Regel.

| Scanner | Regeln | Liquid Glass | Scene |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="Der Scanner-Bildschirm mit einem veralteten App-Delegate und seinen Funden" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="Die durchsuchbare Liste der 42 Regeln" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Glass-Buttons in einem Glass-Effect-Container über einem blauen Farbverlauf" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="Rolle, Fenster, Ausrichtung und Anzeigeskalierung der Window-Scene" width="200"></picture> |

Die Screenshots stammen aus der laufenden App; `scripts/capture-example-screens.sh` nimmt sie neu auf.

## Dokumentation

API-Referenz und Artikel:

- [MigrationScanner auf GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — die API-Referenz
- [Erste Schritte](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Regelreferenz](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — alle 42 Regeln mit ihren Korrekturen

## Anleitungen

- [Den Scene-Lebenszyklus übernehmen](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — Manifest, Scene-Delegate, verschobene Methoden und Ersatz für `UIScreen.main`
- [Liquid Glass übernehmen](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — nicht mehr abwählen, eigene Hintergründe entfernen, umbenannte APIs, Glas auf eigenen Steuerelementen
- [In Xcode und CI ausführen](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — Build-Phase, Anmerkungen in Pull Requests, Code Scanning, JSON

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Toolchain | Swift 6.2 (Xcode 26) |

## Architektur

- `Lexer` zerlegt eine Swift-Datei in Tokens und Kommentare; String-Inhalte und Kommentare werden nie zu Tokens, interpolierter Code schon.
- `BracketIndex` und `TokenIndex` indizieren Bezeichner, Klammerpaare, Argumentlabels und Closure-Parameter in einem Durchlauf, sodass jeder Matcher linear mit der Dateigröße arbeitet.
- `RuleCatalog` enthält die Regeln; jede hat einen Matcher (Token-Folge, Member-Zugriff, Aufruf oder Deklaration mit Argumentlabels oder eine Projektprüfung), einen Schweregrad und ihren SDK-Beleg.
- `ProjectFacts` sammelt für die Projektregeln die Einstiegspunkte der App, Info.plist-Werte und Build-Einstellungen. `PropertyListGuard` lehnt Property Lists ab, die tief verschachtelt, zyklisch oder fehlerhaft sind, bevor der Parser des Systems sie liest.
- `ProjectScanner` durchläuft die Dateien mit Grenzen für Größe und Anzahl und folgt nie symbolischen Links; `ReportFormatter` schreibt die fünf Formate und maskiert Steuerzeichen in Pfaden.
- `MigrationScanCLI` parst und validiert die Kommandozeile; die ausführbare Datei `migration-scan` leitet nur dorthin weiter.

### Bekannte Einschränkungen

- Der Scanner liest Quelltext; er prüft keine Typen. Eine Regel wie `uiapplication-key-window` trifft auf `UIApplication.shared.keyWindow` zu, nicht auf ein `keyWindow`, das über eine andere Variable erreicht wird.
- Die Projektregeln gehen von einer App pro gescanntem Ordner aus: Info.plist-Dateien und Build-Einstellungen irgendwo im Ordner zählen für die App, die dort gefunden wird.
- Es schlägt Ersatz vor und schreibt Code nie um.

## Roadmap

Neue Regeln folgen neuen SDK-Versionen; jede wird mit der SDK-Deklaration hinzugefügt, auf der sie beruht, sowie mit einem Beispiel, das sie melden muss, und einem, das sie in Ruhe lassen muss. Wünsche und Meldungen gehören in die [Issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](CONTRIBUTING.md) und den [Verhaltenskodex](CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
