<!-- i18n-source: README.md@b6354fa4fccc4cdcfbf0e15989f5e4db1e94192b status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

iOS アプリを iOS 26 と iOS 27 SDK に移行するための、コマンドラインツール、Swift ライブラリ、そしてガイド集です。`migration-scan` は Swift のソースコード、Info.plist ファイル、Xcode のビルド設定を読み取り、これらの SDK が非推奨にした点、無視する点、拒否する点を一覧にします。各項目には、代わりに何を書けばよいかと Apple のドキュメントへのリンクが付きます。Xcode が警告を出す前に一覧を手に入れたいアプリ開発者向けのツールで、Xcode が決して報告しない変更も対象です。たとえば、scene manifest を持たない UIKit アプリは iOS 27 SDK でビルドすると起動しませんが、コンパイラはこれについて何も伝えません。

## 主な特長

- **アプリが起動しなくなる問題を見つけます** — scene manifest がない、または manifest に scene の構成が指定されていない UIKit の app delegate は、Apple の TN3187 に従ってエラーとして報告されます。
- **コンパイラが警告しない問題を見つけます** — アプリが scene を使うようになると UIKit が呼ばなくなる app delegate のメソッド、iOS 27 が無視する `UIDesignRequiresCompatibility`、将来のリリースでのみ非推奨になる SwiftUI の API などです。
- **すべてのルールを SDK と照合しています** — 42 個のルールはそれぞれ、根拠にした iOS 27.1 SDK のヘッダまたは Swift インターフェースの宣言を示します（`migration-scan --explain <rule>`）。
- **テキストではなくコードを読みます** — コメントや文字列は一致の対象にならず、文字列補間の中のコードは対象になります。呼び出しと宣言は引数ラベルで照合します。
- **結果を見るあらゆる場所に出力します** — プレーンテキスト、Xcode の issue、GitHub の pull request アノテーション、コードスキャン用の SARIF、そして JSON。レポートにソースコードがコピーされることはありません。
- **ビルドできるコードを載せたガイド** — scene ライフサイクルと Liquid Glass のガイドで、スニペットは CI がビルドしてテストしている MigrationLab サンプルアプリから取っています。

## クイックスタート

**1. スキャナを入手する**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. アプリをスキャンする**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. 報告された点を修正する**

各項目には、場所、理由、代わりに書くべき内容が示されます。[テスト用 fixture](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp) にある旧式アプリの 21 件の検出結果のうち 2 件を示します。

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

まずはエラーから始めてください。[scene ライフサイクルのガイド](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle)では、最もよくあるエラーの対処を順を追って説明しています。

## インストール

### コマンドライン

クイックスタートと同様にクローンからビルドします。コマンドは `.build/release/migration-scan` です。クローンせずに実行するには、別のパッケージの依存関係にこのパッケージを追加し、`swift run migration-scan` を呼び出します。

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

または `Package.swift` の `dependencies` に追加します。

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

## 使い方

### 報告する内容を選ぶ

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

検出結果が `--fail-on` に達すると終了ステータスは 1 になります（デフォルトは `error` で、`warning`、`info`、`never` も指定できます）。コマンドラインが正しくない場合は 2、それ以外は 0 です。

### Xcode に検出結果を表示する

Run Script ビルドフェーズを追加すると、Xcode が各検出結果を issue navigator に一覧表示します。

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

そのターゲットでは `ENABLE_USER_SCRIPT_SANDBOXING` をオフにしてください。オンのままだと、スクリプトがソースを読み取れません。

### pull request にアノテーションを付ける

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

代わりに `--format sarif` を指定すると、GitHub のコードスキャン用のレポートが書き出されます。[CI のガイド](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci)を参照してください。

### 検出結果をあえて残す

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

コードの後ろにあるコメントはその行に、単独の行にあるコメントは次の行に適用されます。`// migration-scan:ignore-file <rules>` はファイル全体に適用されます。未知のルールを指定したコメントは、何も抑制しないまま黙って通されるのではなく、報告されます。

### Swift からスキャンする

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

`scan(source:)` は 1 つのソーステキストを検査します。サンプルアプリは、入力するたびにこれで再スキャンしています。

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### scene ライフサイクルを採用する

移行の核心部分を、サンプルアプリの scene delegate から抜粋します。ウィンドウは window scene に属し、アプリを起動した URL は接続オプションで届きます。

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## デモ

[MigrationLab](Examples/MigrationLab) は、SwiftUI の画面を持つ scene ベースの UIKit アプリです。検出結果をリアルタイムで表示するソースエディタ、ルールカタログ、カスタムコントロール上の Liquid Glass、そして window scene が自身について報告する内容を確認できます。`Examples/MigrationLab/MigrationLab.xcodeproj` を開き、iOS 26 シミュレータで実行してください。`migrationlab://rule/<rule-id>` でルールを開けます。

| スキャナ | ルール | Liquid Glass | Scene |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="旧式の app delegate とその検出結果が表示されたスキャナ画面" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="検索できる 42 個のルールの一覧" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="青いグラデーションの上にある glass effect container 内のガラスボタン" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="window scene の役割、ウィンドウ、向き、表示スケール" width="200"></picture> |

スクリーンショットは実際に動作しているアプリから取得しています。`scripts/capture-example-screens.sh` で撮り直せます。

## ドキュメント

API リファレンスと解説記事：

- [GitHub Pages 上の MigrationScanner](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — API リファレンス
- [はじめに](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [ルールリファレンス](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — 全 42 個のルールと修正方法

## ガイド

- [scene ライフサイクルを採用する](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifest、scene delegate、移動したメソッド、`UIScreen.main` の代替
- [Liquid Glass を採用する](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — オプトアウトをやめる、カスタム背景を取り除く、名前が変わった API、カスタムコントロール上のガラス
- [Xcode と CI で実行する](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — ビルドフェーズ、pull request アノテーション、コードスキャン、JSON

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| ツールチェーン | Swift 6.2 (Xcode 26) |

## アーキテクチャ

- `Lexer` は Swift ファイルをトークンとコメントに分けます。文字列の中身とコメントはトークンになりませんが、補間されたコードはトークンになります。
- `BracketIndex` と `TokenIndex` は、識別子、括弧のペア、引数ラベル、クロージャのパラメータを 1 回の走査でインデックス化します。そのため、すべてのマッチャーはファイルサイズに対して線形時間で動作します。
- `RuleCatalog` はルールを保持します。各ルールには、マッチャー（トークン列、メンバーアクセス、引数ラベル付きの呼び出しまたは宣言、あるいはプロジェクトのチェック）、重大度、SDK の根拠があります。
- `ProjectFacts` は、プロジェクトのルール用に、アプリのエントリポイント、Info.plist の値、ビルド設定を集めます。`PropertyListGuard` は、深くネストされている、循環している、または不正な形式のプロパティリストを、システムのパーサーが読む前に拒否します。
- `ProjectScanner` は、サイズと数の上限を守りながらファイルをたどり、シンボリックリンクは決してたどりません。`ReportFormatter` は 5 つの形式を書き出し、パス内の制御文字をエスケープします。
- `MigrationScanCLI` はコマンドラインを解析して検証します。`migration-scan` 実行ファイルは、そこへ処理を渡すだけです。

### 既知の制限

- スキャナはソースのテキストを読むだけで、型チェックはしません。`uiapplication-key-window` のようなルールは `UIApplication.shared.keyWindow` には一致しますが、別の変数を経由した `keyWindow` には一致しません。
- プロジェクトのルールは、スキャンするフォルダごとにアプリが 1 つあることを前提としています。フォルダ内のどこにある Info.plist ファイルとビルド設定も、そこで見つかったアプリのものとして扱われます。
- 置き換えを提案するだけで、コードを書き換えることはありません。

## ロードマップ

新しいルールは新しい SDK のリリースに合わせて追加します。どのルールも、根拠となる SDK の宣言と、必ず報告されるサンプル、および報告されてはならないサンプルを添えて追加されます。要望や報告は [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues) にお寄せください。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](CONTRIBUTING.md)と[行動規範](CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
