<!-- i18n-source: README.md@b6354fa4fccc4cdcfbf0e15989f5e4db1e94192b status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Última versión: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

Una herramienta de línea de comandos, una biblioteca de Swift y un conjunto de guías para migrar una app de iOS a los SDK de iOS 26 y iOS 27. `migration-scan` lee tus fuentes de Swift, los archivos Info.plist y los ajustes de compilación de Xcode, y enumera lo que esos SDK dejan obsoleto, ignoran o rechazan, cada elemento con lo que debes escribir en su lugar y un enlace a la documentación de Apple. Está pensada para desarrolladores de apps que quieren tener la lista antes de que Xcode se la muestre, o para cambios que Xcode nunca notifica: una app de UIKit sin manifiesto de escenas no se inicia cuando se compila con el SDK de iOS 27, y el compilador no dice nada al respecto.

## Lo más destacado

- **Encuentra lo que impide que una app se inicie**: un app delegate de UIKit sin manifiesto de escenas, o con un manifiesto que no indica ninguna configuración de escena, se notifica como un error, siguiendo la TN3187 de Apple.
- **Encuentra lo que el compilador no advierte**: métodos del app delegate que UIKit deja de llamar cuando la app usa escenas, `UIDesignRequiresCompatibility`, que iOS 27 ignora, y API de SwiftUI que solo quedará obsoleta en una versión futura.
- **Cada regla se comprueba contra el SDK**: cada una de las 42 reglas indica la declaración de los encabezados del SDK de iOS 27.1 o de las interfaces de Swift en la que se basa (`migration-scan --explain <rule>`).
- **Lee código, no texto**: los comentarios y las cadenas nunca coinciden, el código dentro de interpolaciones de cadenas sí, y las llamadas y declaraciones coinciden según sus etiquetas de argumento.
- **Salida para cada lugar donde mires**: texto sin formato, incidencias de Xcode, anotaciones de pull requests de GitHub, SARIF para el análisis de código y JSON. Los informes nunca copian código fuente.
- **Guías con código que compila**: guías del ciclo de vida de escenas y de Liquid Glass cuyos fragmentos proceden de la app de ejemplo MigrationLab, que CI compila y prueba.

## Inicio rápido

**1. Consigue el escáner**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Escanea tu app**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Corrige lo que informa**

Cada hallazgo indica dónde, por qué y qué escribir en su lugar. Dos de los 21 hallazgos de la app heredada de [los fixtures de pruebas](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp):

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

Empieza por los errores. La [guía del ciclo de vida de escenas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) explica paso a paso el más habitual.

## Instalación

### Línea de comandos

Compílala desde un clon como en el inicio rápido; el comando es `.build/release/migration-scan`. Para ejecutarla sin clonar, añade el paquete a las dependencias de otro paquete y llama a `swift run migration-scan`.

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

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

## Uso

### Elige qué informar

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

El estado de salida es 1 cuando un hallazgo alcanza `--fail-on` (`error` por defecto; también `warning`, `info` o `never`), 2 si la línea de comandos es incorrecta y 0 en los demás casos.

### Muestra los hallazgos en Xcode

Añade una fase de compilación Run Script; Xcode muestra cada hallazgo en el navegador de incidencias:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Desactiva `ENABLE_USER_SCRIPT_SANDBOXING` en ese target; de lo contrario, el script no puede leer las fuentes.

### Anota los pull requests

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` escribe en su lugar un informe para el análisis de código de GitHub; consulta la [guía de CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Conserva un hallazgo a propósito

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Un comentario después del código se aplica a su línea, un comentario en su propia línea se aplica a la línea siguiente, y `// migration-scan:ignore-file <rules>` se aplica a todo el archivo. Un comentario que nombra una regla desconocida se notifica, en lugar de no suprimir nada en silencio.

### Escanea desde Swift

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

`scan(source:)` comprueba un único texto fuente, que es como la app de ejemplo vuelve a escanear mientras escribes:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Adopta el ciclo de vida de escenas

El núcleo de la migración, tomado del scene delegate de la app de ejemplo: la ventana pertenece a la escena de ventana, y la URL que inició la app llega en las opciones de conexión.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Demo

[MigrationLab](Examples/MigrationLab) es una app de UIKit basada en escenas con pantallas de SwiftUI: un editor de código fuente con hallazgos en vivo, el catálogo de reglas, Liquid Glass en un control personalizado y lo que la escena de ventana informa sobre sí misma. Abre `Examples/MigrationLab/MigrationLab.xcodeproj` y ejecútala en un simulador de iOS 26. `migrationlab://rule/<rule-id>` abre una regla.

| Escáner | Reglas | Liquid Glass | Escena |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="La pantalla del escáner con un app delegate heredado y sus hallazgos" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="La lista con búsqueda de las 42 reglas" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Botones de cristal en un contenedor de efecto de cristal sobre un degradado azul" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="El rol, las ventanas, la orientación y la escala de pantalla de la escena de ventana" width="200"></picture> |

Las capturas de pantalla proceden de la app en ejecución; `scripts/capture-example-screens.sh` las vuelve a tomar.

## Documentación

Referencia de la API y artículos:

- [MigrationScanner en GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/): la referencia de la API
- [Primeros pasos](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Referencia de reglas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference): las 42 reglas con sus correcciones

## Guías

- [Adoptar el ciclo de vida de escenas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle): manifiesto, scene delegate, métodos que cambian de lugar y sustitutos de `UIScreen.main`
- [Adoptar Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass): deja de excluirte, elimina los fondos personalizados, API con nombres nuevos, cristal en controles personalizados
- [Ejecutar en Xcode y CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci): fase de compilación, anotaciones de pull requests, análisis de código, JSON

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Herramientas | Swift 6.2 (Xcode 26) |

## Arquitectura

- `Lexer` convierte un archivo de Swift en tokens y comentarios; el contenido de las cadenas y los comentarios nunca se convierten en tokens, pero el código interpolado sí.
- `BracketIndex` y `TokenIndex` indexan en una sola pasada los identificadores, los pares de corchetes, las etiquetas de argumento y los parámetros de closures, de modo que cada comparador es lineal respecto al tamaño del archivo.
- `RuleCatalog` contiene las reglas; cada una tiene un comparador (secuencia de tokens, acceso a un miembro, llamada o declaración con etiquetas de argumento, o una comprobación de proyecto), una gravedad y su evidencia en el SDK.
- `ProjectFacts` recopila los puntos de entrada de la app, los valores de Info.plist y los ajustes de compilación para las reglas de proyecto. `PropertyListGuard` rechaza las listas de propiedades con anidamiento profundo, cíclicas o mal formadas antes de que las lea el analizador del sistema.
- `ProjectScanner` recorre los archivos con límites de tamaño y de cantidad y nunca sigue enlaces simbólicos; `ReportFormatter` escribe los cinco formatos y escapa los caracteres de control en las rutas.
- `MigrationScanCLI` analiza y valida la línea de comandos; el ejecutable `migration-scan` solo le reenvía la llamada.

### Limitaciones conocidas

- El escáner lee texto fuente; no comprueba tipos. Una regla como `uiapplication-key-window` coincide con `UIApplication.shared.keyWindow`, no con un `keyWindow` al que se llega a través de otra variable.
- Las reglas de proyecto suponen una app por carpeta escaneada: los archivos Info.plist y los ajustes de compilación que haya en cualquier parte de la carpeta cuentan para la app que se encuentra allí.
- Sugiere sustituciones y nunca reescribe código.

## Hoja de ruta

Las reglas nuevas siguen a las nuevas versiones del SDK; cada una se añade con la declaración del SDK en la que se basa, un ejemplo que debe informar y otro que debe dejar en paz. Las solicitudes y los informes van a las [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](CONTRIBUTING.md) y el [código de conducta](CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
