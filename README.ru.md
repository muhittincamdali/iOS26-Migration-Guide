<!-- i18n-source: README.md@160fc1ab707277cda7e31fd2d880426e457f1746 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Утилита командной строки, библиотека на Swift и набор руководств для перехода приложения iOS на SDK iOS 26 и iOS 27. `migration-scan` читает ваши исходники на Swift, файлы Info.plist и настройки сборки Xcode и перечисляет то, что эти SDK объявляют устаревшим, игнорируют или отклоняют; для каждого пункта указано, что писать вместо него, и дана ссылка на документацию Apple. Инструмент предназначен для разработчиков приложений, которым нужен этот список раньше, чем его покажет Xcode, и для изменений, о которых Xcode не сообщает вовсе: приложение на UIKit без манифеста сцен не запускается, если собрано с SDK iOS 27, а компилятор об этом молчит.

## Основные возможности

- **Находит то, из-за чего приложение не запускается** — делегат приложения UIKit без манифеста сцен или с манифестом, в котором не указана ни одна конфигурация сцены, сообщается как ошибка в соответствии с TN3187 от Apple.
- **Находит то, о чём компилятор не предупреждает** — методы делегата приложения, которые UIKit перестаёт вызывать, как только приложение начинает использовать сцены, `UIDesignRequiresCompatibility`, который iOS 27 игнорирует, и API SwiftUI, объявленные устаревшими только в будущем выпуске.
- **Каждое правило сверено с SDK** — каждое из 42 правил указывает объявление в заголовках SDK iOS 27.1 или в интерфейсах Swift, на котором оно основано (`migration-scan --explain <rule>`).
- **Читает код, а не текст** — комментарии и строки никогда не дают совпадений, код внутри интерполяции строк даёт, а вызовы и объявления сопоставляются по меткам аргументов.
- **Вывод для любого места, где вы смотрите результат** — обычный текст, проблемы Xcode, аннотации к pull request на GitHub, SARIF для сканирования кода и JSON. Отчёты никогда не копируют исходный код.
- **Руководства с кодом, который собирается** — руководства по жизненному циклу сцен и по Liquid Glass, фрагменты кода в которых взяты из демонстрационного приложения MigrationLab, которое CI собирает и тестирует.

## Быстрый старт

**1. Получите сканер**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Просканируйте приложение**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Исправьте найденное**

Каждая находка сообщает, где, почему и что писать вместо этого. Две из 21 находки для устаревшего приложения из [тестовых фикстур](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp):

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

Начните с ошибок. [Руководство по жизненному циклу сцен](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) шаг за шагом разбирает самую распространённую из них.

## Установка

### Командная строка

Соберите утилиту из клона, как в разделе «Быстрый старт»; команда — `.build/release/migration-scan`. Чтобы запустить её без клона, добавьте пакет в зависимости другого пакета и вызовите `swift run migration-scan`.

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

## Использование

### Выбор того, о чём сообщать

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

Код завершения равен 1, когда находка достигает уровня `--fail-on` (по умолчанию `error`; также `warning`, `info` или `never`), 2 — при неверной командной строке и 0 — во всех остальных случаях.

### Показ находок в Xcode

Добавьте этап сборки Run Script; Xcode покажет каждую находку в навигаторе проблем:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Отключите `ENABLE_USER_SCRIPT_SANDBOXING` для этой цели сборки, иначе скрипт не сможет читать исходники.

### Аннотации к pull request

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` вместо этого записывает отчёт для сканирования кода на GitHub; см. [руководство по CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Сознательно оставить находку

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Комментарий после кода относится к его строке, комментарий на отдельной строке — к следующей строке, а `// migration-scan:ignore-file <rules>` — ко всему файлу. Комментарий с названием неизвестного правила попадает в отчёт, а не молча ничего не подавляет.

### Сканирование из Swift

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

`scan(source:)` проверяет один фрагмент исходного текста; именно так демонстрационное приложение пересканирует код, пока вы набираете:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Переход на жизненный цикл сцен

Суть перехода — в делегате сцены демонстрационного приложения: окно принадлежит оконной сцене, а URL, с которого запущено приложение, приходит в параметрах подключения.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Демо

[MigrationLab](Examples/MigrationLab) — это приложение UIKit на основе сцен с экранами на SwiftUI: редактор исходного кода с находками в реальном времени, каталог правил, Liquid Glass на нестандартном элементе управления и то, что оконная сцена сообщает о себе. Откройте `Examples/MigrationLab/MigrationLab.xcodeproj` и запустите его на симуляторе iOS 26. `migrationlab://rule/<rule-id>` открывает правило.

| Сканер | Правила | Liquid Glass | Сцена |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="Экран сканера с устаревшим делегатом приложения и его находками" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="Список из 42 правил с поиском" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Стеклянные кнопки в контейнере стеклянного эффекта на синем градиенте" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="Роль оконной сцены, её окна, ориентация и масштаб отображения" width="200"></picture> |

Скриншоты сделаны в работающем приложении; `scripts/capture-example-screens.sh` снимает их заново.

## Документация

Справочник API и статьи:

- [MigrationScanner на GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — справочник по API
- [Начало работы](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Справочник правил](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — все 42 правила с исправлениями

## Руководства

- [Переход на жизненный цикл сцен](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — манифест, делегат сцены, перенесённые методы и замены для `UIScreen.main`
- [Переход на Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — перестать отказываться от него, убрать нестандартные фоны, переименованные API, стекло на нестандартных элементах управления
- [Запуск в Xcode и CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — этап сборки, аннотации к pull request, сканирование кода, JSON

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Инструменты | Swift 6.2 (Xcode 26) |

## Архитектура

- `Lexer` превращает файл Swift в токены и комментарии; содержимое строк и комментарии токенами не становятся, а интерполируемый код — становится.
- `BracketIndex` и `TokenIndex` за один проход индексируют идентификаторы, пары скобок, метки аргументов и параметры замыканий, поэтому каждый сопоставитель работает за время, линейное по размеру файла.
- `RuleCatalog` хранит правила; у каждого есть сопоставитель (последовательность токенов, обращение к члену, вызов или объявление с метками аргументов либо проверка проекта), уровень серьёзности и подтверждение из SDK.
- `ProjectFacts` собирает для правил проекта точки входа приложения, значения Info.plist и настройки сборки. `PropertyListGuard` отклоняет списки свойств с глубокой вложенностью, циклами или ошибками формата, прежде чем их прочитает системный разборщик.
- `ProjectScanner` обходит файлы с ограничениями по размеру и количеству и никогда не переходит по символическим ссылкам; `ReportFormatter` записывает пять форматов и экранирует управляющие символы в путях.
- `MigrationScanCLI` разбирает и проверяет командную строку; исполняемый файл `migration-scan` лишь передаёт управление ему.

### Известные ограничения

- Сканер читает исходный текст и не проверяет типы. Правило вроде `uiapplication-key-window` срабатывает на `UIApplication.shared.keyWindow`, но не на `keyWindow`, полученный через другую переменную.
- Правила проекта исходят из того, что в сканируемой папке одно приложение: файлы Info.plist и настройки сборки в любом месте папки относятся к найденному там приложению.
- Сканер предлагает замены и никогда не переписывает код.

## План развития

Новые правила появляются вслед за новыми выпусками SDK; каждое добавляется вместе с объявлением SDK, на котором оно основано, одним примером, о котором оно должно сообщать, и одним, который оно должно оставлять в покое. Пожелания и сообщения об ошибках отправляйте в [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](CONTRIBUTING.md) и [кодекс поведения](CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
