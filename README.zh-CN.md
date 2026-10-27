<!-- i18n-source: README.md@b6354fa4fccc4cdcfbf0e15989f5e4db1e94192b status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

一个命令行工具、一个 Swift 库和一组指南，帮助你把 iOS 应用迁移到 iOS 26 和 iOS 27 SDK。`migration-scan` 会读取你的 Swift 源代码、Info.plist 文件和 Xcode 构建设置，列出这些 SDK 弃用、忽略或拒绝的内容，每一项都附有应改用的写法以及指向 Apple 文档的链接。它面向希望在 Xcode 报出问题之前就拿到清单的应用开发者，也适用于 Xcode 从不提示的变更：没有 scene manifest 的 UIKit 应用用 iOS 27 SDK 构建后无法启动，而编译器对此只字不提。

## 亮点

- **找出会导致应用无法启动的问题** — 没有 scene manifest，或 manifest 中没有指定任何 scene 配置的 UIKit app delegate，会按照 Apple 的 TN3187 报告为错误。
- **找出编译器不会警告的问题** — 应用改用 scene 后 UIKit 不再调用的 app delegate 方法、iOS 27 会忽略的 `UIDesignRequiresCompatibility`，以及仅在未来版本中才会弃用的 SwiftUI API。
- **每条规则都对照 SDK 核实** — 42 条规则中的每一条，都会指明它所依据的、位于 iOS 27.1 SDK 头文件或 Swift 接口中的声明（`migration-scan --explain <rule>`）。
- **读的是代码，不是文本** — 注释和字符串永远不会匹配，字符串插值中的代码会匹配，调用和声明则按参数标签匹配。
- **适配你查看结果的每个地方的输出** — 纯文本、Xcode 问题、GitHub pull request 注释、用于代码扫描的 SARIF，以及 JSON。报告不会复制源代码。
- **代码可以构建的指南** — scene 生命周期和 Liquid Glass 指南，其中的代码片段来自由 CI 构建并测试的 MigrationLab 示例应用。

## 快速开始

**1. 获取扫描器**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. 扫描你的应用**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. 修复报告的问题**

每条发现都会说明位置、原因以及应改用的写法。下面是[测试 fixtures](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp) 中旧版应用的 21 条发现里的两条：

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

先从错误开始。[scene 生命周期指南](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle)会一步步带你处理其中最常见的一个。

## 安装

### 命令行

按快速开始中的方式从克隆的仓库构建；命令是 `.build/release/migration-scan`。如果不想克隆，可以把该软件包添加到另一个软件包的依赖中，然后调用 `swift run migration-scan`。

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

## 使用方法

### 选择要报告的内容

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

当某条发现达到 `--fail-on` 指定的级别时，退出状态为 1（默认是 `error`，也可以是 `warning`、`info` 或 `never`）；命令行有误时为 2；其余情况为 0。

### 在 Xcode 中显示发现

添加一个 Run Script 构建阶段，Xcode 会在 issue navigator 中列出每条发现：

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

请为该 target 关闭 `ENABLE_USER_SCRIPT_SANDBOXING`，否则脚本无法读取源代码。

### 为 pull request 添加注释

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` 则会改为写出供 GitHub 代码扫描使用的报告，参见 [CI 指南](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci)。

### 有意保留某条发现

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

代码后面的注释作用于它所在的行，单独成行的注释作用于下一行，`// migration-scan:ignore-file <rules>` 则作用于整个文件。如果注释中写了未知的规则，工具会报告它，而不是悄悄地什么也不抑制。

### 在 Swift 中扫描

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

`scan(source:)` 检查单段源代码文本，示例应用就是用它在你输入时重新扫描的：

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### 迁移到 scene 生命周期

迁移的核心来自示例应用的 scene delegate：窗口归属于 window scene，启动应用的 URL 则通过连接选项传入。

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## 演示

[MigrationLab](Examples/MigrationLab) 是一个基于 scene 的 UIKit 应用，带有 SwiftUI 界面：包括实时显示发现的源代码编辑器、规则目录、自定义控件上的 Liquid Glass，以及 window scene 报告的自身信息。打开 `Examples/MigrationLab/MigrationLab.xcodeproj`，在 iOS 26 模拟器上运行。`migrationlab://rule/<rule-id>` 会打开对应的规则。

| 扫描器 | 规则 | Liquid Glass | Scene |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="扫描器界面，显示一个旧版 app delegate 及其发现" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="可搜索的 42 条规则列表" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="蓝色渐变背景上、位于 glass effect container 中的玻璃按钮" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="window scene 的角色、窗口、方向和显示缩放比例" width="200"></picture> |

截图来自正在运行的应用；`scripts/capture-example-screens.sh` 可以重新截取。

## 文档

API 参考文档与文章：

- [GitHub Pages 上的 MigrationScanner](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — API 参考
- [入门](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [规则参考](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — 全部 42 条规则及其修复方法

## 指南

- [迁移到 scene 生命周期](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifest、scene delegate、被移走的方法，以及 `UIScreen.main` 的替代写法
- [采用 Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — 停止选择退出 Liquid Glass、移除自定义背景、被重命名的 API、自定义控件上的玻璃效果
- [在 Xcode 和 CI 中运行](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — 构建阶段、pull request 注释、代码扫描、JSON

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| 工具链 | Swift 6.2 (Xcode 26) |

## 架构

- `Lexer` 把 Swift 文件拆成 token 和注释；字符串内容和注释永远不会成为 token，插值中的代码则会。
- `BracketIndex` 和 `TokenIndex` 一次遍历就为标识符、括号对、参数标签和闭包参数建立索引，因此每个匹配器的耗时都与文件大小成线性关系。
- `RuleCatalog` 保存所有规则；每条规则有一个匹配器（token 序列、成员访问、带参数标签的调用或声明，或项目检查）、一个严重级别以及它的 SDK 依据。
- `ProjectFacts` 为项目规则收集应用入口点、Info.plist 的值和构建设置。`PropertyListGuard` 会在系统解析器读取之前，拒绝嵌套过深、存在循环或格式错误的属性列表。
- `ProjectScanner` 在大小和数量限制内遍历文件，且从不跟随符号链接；`ReportFormatter` 写出五种格式，并转义路径中的控制字符。
- `MigrationScanCLI` 负责解析并校验命令行；`migration-scan` 可执行文件只是把调用转发给它。

### 已知限制

- 扫描器读取的是源代码文本，不做类型检查。像 `uiapplication-key-window` 这样的规则匹配的是 `UIApplication.shared.keyWindow`，而不是通过其他变量访问到的 `keyWindow`。
- 项目规则假定每个被扫描的文件夹只包含一个应用：文件夹中任何位置的 Info.plist 文件和构建设置，都算作在那里找到的应用的。
- 它只给出替换建议，从不改写代码。

## 路线图

新规则随新的 SDK 版本而来；每条规则都附带它所依据的 SDK 声明，以及一个它必须报告的示例和一个它必须放过的示例。需求和反馈请提交到 [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues)。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](CONTRIBUTING.md)和[行为准则](CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
