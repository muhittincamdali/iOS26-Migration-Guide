<!-- i18n-source: README.md@160fc1ab707277cda7e31fd2d880426e457f1746 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Un outil en ligne de commande, une bibliothèque Swift et un ensemble de guides pour faire passer une app iOS aux SDK d’iOS 26 et d’iOS 27. `migration-scan` lit vos sources Swift, vos fichiers Info.plist et les réglages de compilation d’Xcode, puis liste ce que ces SDK déprécient, ignorent ou refusent, avec pour chaque élément ce qu’il faut écrire à la place et un lien vers la documentation d’Apple. Il s’adresse aux développeurs d’apps qui veulent la liste avant qu’Xcode ne l’affiche, ou pour les changements qu’Xcode ne signale jamais : une app UIKit sans manifeste de scènes ne se lance pas quand elle est compilée avec le SDK d’iOS 27, et le compilateur n’en dit rien.

## Points forts

- **Repère ce qui empêche une app de se lancer** — un app delegate UIKit sans manifeste de scènes, ou dont le manifeste ne nomme aucune configuration de scène, est signalé comme une erreur, conformément à la TN3187 d’Apple.
- **Repère ce que le compilateur ne signale pas** — les méthodes de l’app delegate qu’UIKit cesse d’appeler dès que l’app utilise des scènes, `UIDesignRequiresCompatibility`, qu’iOS 27 ignore, et les API SwiftUI qui ne seront dépréciées que dans une version future.
- **Chaque règle est vérifiée par rapport au SDK** — chacune des 42 règles nomme la déclaration, dans les en-têtes du SDK d’iOS 27.1 ou dans les interfaces Swift, sur laquelle elle repose (`migration-scan --explain <rule>`).
- **Lit le code, pas le texte** — les commentaires et les chaînes ne produisent jamais de correspondance, le code à l’intérieur des interpolations de chaînes si, et les appels et les déclarations correspondent selon leurs étiquettes d’argument.
- **Une sortie pour chaque endroit où vous regardez** — texte brut, problèmes Xcode, annotations de pull requests GitHub, SARIF pour l’analyse de code et JSON. Les rapports ne copient jamais le code source.
- **Des guides dont le code compile** — des guides sur le cycle de vie des scènes et sur Liquid Glass dont les extraits proviennent de l’app d’exemple MigrationLab, que la CI compile et teste.

## Démarrage rapide

**1. Récupérer le scanner**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Analyser votre app**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Corriger ce qui est signalé**

Chaque résultat indique où, pourquoi et ce qu’il faut écrire à la place. Deux des 21 résultats pour l’app héritée des [fixtures de test](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp) :

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

Commencez par les erreurs. Le [guide du cycle de vie des scènes](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) détaille pas à pas la plus courante.

## Installation

### Ligne de commande

Compilez-le depuis un clone comme dans le démarrage rapide ; la commande est `.build/release/migration-scan`. Pour l’exécuter sans clone, ajoutez le paquet aux dépendances d’un autre paquet et appelez `swift run migration-scan`.

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

## Utilisation

### Choisir ce qui est signalé

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

Le code de sortie est 1 quand un résultat atteint le niveau `--fail-on` (`error` par défaut ; `warning`, `info` ou `never` sont possibles), 2 pour une ligne de commande incorrecte, et 0 dans les autres cas.

### Afficher les résultats dans Xcode

Ajoutez une phase de compilation Run Script ; Xcode liste chaque résultat dans le navigateur de problèmes :

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Désactivez `ENABLE_USER_SCRIPT_SANDBOXING` pour cette cible, sans quoi le script ne peut pas lire les sources.

### Annoter les pull requests

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` écrit à la place un rapport pour l’analyse de code de GitHub ; consultez le [guide CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Conserver un résultat volontairement

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Un commentaire placé après le code s’applique à sa ligne, un commentaire sur sa propre ligne s’applique à la ligne suivante, et `// migration-scan:ignore-file <rules>` s’applique au fichier entier. Un commentaire qui nomme une règle inconnue est signalé, au lieu de ne rien supprimer en silence.

### Analyser depuis Swift

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

`scan(source:)` analyse un seul texte source, ce qui permet à l’app d’exemple de relancer l’analyse pendant que vous tapez :

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Adopter le cycle de vie des scènes

Le cœur de la migration, tiré du scene delegate de l’app d’exemple : la fenêtre appartient à la scène de fenêtre, et l’URL qui a lancé l’app arrive dans les options de connexion.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Démo

[MigrationLab](Examples/MigrationLab) est une app UIKit basée sur les scènes, avec des écrans SwiftUI : un éditeur de code source qui affiche les résultats en direct, le catalogue de règles, Liquid Glass sur un contrôle personnalisé, et ce que la scène de fenêtre indique sur elle-même. Ouvrez `Examples/MigrationLab/MigrationLab.xcodeproj` et lancez-la sur un simulateur iOS 26. `migrationlab://rule/<rule-id>` ouvre une règle.

| Scanner | Règles | Liquid Glass | Scène |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="L’écran du scanner avec un app delegate hérité et ses résultats" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="La liste consultable des 42 règles" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Des boutons en verre dans un conteneur à effet de verre sur un dégradé bleu" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="Le rôle, les fenêtres, l’orientation et l’échelle d’affichage de la scène de fenêtre" width="200"></picture> |

Les captures d’écran proviennent de l’app en cours d’exécution ; `scripts/capture-example-screens.sh` les refait.

## Documentation

Référence de l’API et articles :

- [MigrationScanner sur GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — la référence de l’API
- [Premiers pas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Référence des règles](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — les 42 règles avec leurs corrections

## Guides

- [Adopter le cycle de vie des scènes](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifeste, scene delegate, méthodes déplacées et remplaçants de `UIScreen.main`
- [Adopter Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — cesser de s’en exclure, supprimer les arrière-plans personnalisés, API renommées, verre sur les contrôles personnalisés
- [Exécuter dans Xcode et en CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — phase de compilation, annotations de pull requests, analyse de code, JSON

## Prérequis

| Plateforme | Version minimale |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Chaîne d’outils | Swift 6.2 (Xcode 26) |

## Architecture

- `Lexer` transforme un fichier Swift en tokens et en commentaires ; le contenu des chaînes et les commentaires ne deviennent jamais des tokens, le code interpolé si.
- `BracketIndex` et `TokenIndex` indexent en un seul passage les identifiants, les paires de crochets, les étiquettes d’argument et les paramètres de closures, si bien que chaque détecteur est linéaire en fonction de la taille du fichier.
- `RuleCatalog` contient les règles ; chacune a un détecteur (séquence de tokens, accès à un membre, appel ou déclaration avec étiquettes d’argument, ou vérification de projet), une gravité et sa preuve dans le SDK.
- `ProjectFacts` collecte les points d’entrée de l’app, les valeurs d’Info.plist et les réglages de compilation pour les règles de projet. `PropertyListGuard` refuse les listes de propriétés profondément imbriquées, cycliques ou malformées avant que l’analyseur du système ne les lise.
- `ProjectScanner` parcourt les fichiers avec des limites de taille et de nombre et ne suit jamais les liens symboliques ; `ReportFormatter` écrit les cinq formats et échappe les caractères de contrôle dans les chemins.
- `MigrationScanCLI` analyse et valide la ligne de commande ; l’exécutable `migration-scan` ne fait que lui transmettre l’appel.

### Limites connues

- Le scanner lit le texte source ; il ne vérifie pas les types. Une règle comme `uiapplication-key-window` correspond à `UIApplication.shared.keyWindow`, pas à un `keyWindow` atteint par une autre variable.
- Les règles de projet supposent une seule app par dossier analysé : les fichiers Info.plist et les réglages de compilation situés n’importe où dans le dossier comptent pour l’app qui s’y trouve.
- Il suggère des remplacements et ne réécrit jamais le code.

## Feuille de route

Les nouvelles règles suivent les nouvelles versions du SDK ; chacune est ajoutée avec la déclaration du SDK sur laquelle elle repose, un exemple qu’elle doit signaler et un autre qu’elle doit laisser tranquille. Les demandes et les signalements vont dans les [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](CONTRIBUTING.md) et le [code de conduite](CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
