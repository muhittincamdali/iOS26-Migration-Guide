<!-- i18n-source: README.md@160fc1ab707277cda7e31fd2d880426e457f1746 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/banner-light.svg" alt="iOS 26 Migration Guide: Find what the iOS 26 and iOS 27 SDKs deprecate or refuse in your app, and fix it step by step."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS26-Migration-Guide/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 17+ · macOS 14+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/iOS26-Migration-Guide/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS26-Migration-Guide/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

Uma ferramenta de linha de comando, uma biblioteca Swift e um conjunto de guias para migrar um app iOS para os SDKs do iOS 26 e do iOS 27. O `migration-scan` lê seus fontes Swift, arquivos Info.plist e ajustes de build do Xcode e lista o que esses SDKs descontinuam, ignoram ou recusam, cada item com o que escrever no lugar e um link para a documentação da Apple. Ele é para desenvolvedores de apps que querem a lista antes de o Xcode mostrá-la, ou que precisam das mudanças que o Xcode nunca informa: um app UIKit sem manifesto de cenas não abre quando compilado com o SDK do iOS 27, e o compilador não diz nada sobre isso.

## Destaques

- **Encontra o que impede um app de abrir** — um app delegate de UIKit sem manifesto de cenas, ou com um manifesto que não indica nenhuma configuração de cena, é relatado como erro, seguindo a TN3187 da Apple.
- **Encontra o que o compilador não avisa** — métodos do app delegate que o UIKit deixa de chamar quando o app passa a usar cenas, `UIDesignRequiresCompatibility`, que o iOS 27 ignora, e APIs do SwiftUI que só serão descontinuadas em uma versão futura.
- **Cada regra é verificada com o SDK** — cada uma das 42 regras cita a declaração, nos cabeçalhos do SDK do iOS 27.1 ou nas interfaces Swift, em que se baseia (`migration-scan --explain <rule>`).
- **Lê código, não texto** — comentários e strings nunca geram correspondência, o código dentro de interpolações de string gera, e chamadas e declarações são casadas pelos rótulos de argumento.
- **Saída para todo lugar em que você olha** — texto simples, issues do Xcode, anotações em pull requests do GitHub, SARIF para a verificação de código e JSON. Os relatórios nunca copiam código-fonte.
- **Guias com código que compila** — guias do ciclo de vida de cenas e do Liquid Glass cujos trechos vêm do app de exemplo MigrationLab, que o CI compila e testa.

## Início rápido

**1. Obtenha o scanner**

```sh
git clone https://github.com/muhittincamdali/iOS26-Migration-Guide.git
cd iOS26-Migration-Guide
swift build -c release
```

**2. Escaneie seu app**

```sh
.build/release/migration-scan ~/Developer/MyApp
```

**3. Corrija o que ele relata**

Cada achado diz onde, por quê e o que escrever no lugar. Dois dos 21 achados do app legado nas [fixtures de teste](Tests/MigrationScannerTests/Fixtures/LegacyApp/LegacyApp):

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

Comece pelos erros. O [guia do ciclo de vida de cenas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) explica passo a passo o mais comum deles.

## Instalação

### Linha de comando

Compile a partir de um clone, como no início rápido; o comando é `.build/release/migration-scan`. Para executá-lo sem clonar, adicione o pacote às dependências de outro pacote e chame `swift run migration-scan`.

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/iOS26-Migration-Guide.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

### Escolha o que relatar

```sh
migration-scan --min-severity warning MyApp                      # errors and warnings only
migration-scan --disable navigation-view,foreground-color MyApp  # skip rules
migration-scan --only scene-manifest-missing MyApp               # run only these rules
migration-scan --exclude Generated MyApp                         # skip folders by name
migration-scan --list-rules                                      # every rule
```

O status de saída é 1 quando um achado atinge `--fail-on` (`error` por padrão; também `warning`, `info` ou `never`), 2 para uma linha de comando incorreta e 0 nos demais casos.

### Mostre os achados no Xcode

Adicione uma fase de build Run Script; o Xcode lista cada achado no navegador de issues:

```sh
"$HOME/Developer/iOS26-Migration-Guide/.build/release/migration-scan" --format xcode --fail-on never "$SRCROOT"
```

Desative `ENABLE_USER_SCRIPT_SANDBOXING` nesse target, ou o script não consegue ler os fontes.

### Anote pull requests

```yaml
- uses: actions/checkout@v7
  with:
    repository: muhittincamdali/iOS26-Migration-Guide
    path: .migration-scan
- run: |
    swift build -c release --package-path .migration-scan
    .migration-scan/.build/release/migration-scan --format github .
```

`--format sarif` grava, em vez disso, um relatório para a verificação de código do GitHub; veja o [guia de CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci).

### Mantenha um achado de propósito

```swift
Text(caption)
    .foregroundColor(.secondary) // migration-scan:ignore foreground-color -- shared with the iOS 17 widget
```

Um comentário depois do código vale para a sua linha, um comentário em uma linha própria vale para a linha seguinte, e `// migration-scan:ignore-file <rules>` vale para o arquivo inteiro. Um comentário que cita uma regra desconhecida é relatado, em vez de silenciosamente não suprimir nada.

### Escaneie a partir do Swift

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

`scan(source:)` verifica um único texto-fonte, que é como o app de exemplo escaneia de novo enquanto você digita:

```swift
func findings(in source: String) -> [String] {
    ProjectScanner().scan(source: source).findings.compactMap { finding in
        guard let rule = finding.rule, let location = finding.location else { return nil }
        return "\(location.line):\(location.column) \(rule.title): \(rule.replacement)"
    }
}
```

### Adote o ciclo de vida de cenas

O núcleo da migração, no scene delegate do app de exemplo: a janela pertence à cena de janela, e a URL que abriu o app chega nas opções de conexão.

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LabTabBarController(model: model)
    self.window = window
    window.makeKeyAndVisible()
```

## Demonstração

O [MigrationLab](Examples/MigrationLab) é um app UIKit baseado em cenas com telas em SwiftUI: um editor de código-fonte com achados ao vivo, o catálogo de regras, o Liquid Glass em um controle personalizado e o que a cena de janela informa sobre si mesma. Abra `Examples/MigrationLab/MigrationLab.xcodeproj` e execute em um simulador do iOS 26. `migrationlab://rule/<rule-id>` abre uma regra.

| Scanner | Regras | Liquid Glass | Cena |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scanner-dark.png"><img src="docs/images/example-scanner-light.png" alt="A tela do scanner com um app delegate legado e seus achados" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-rules-dark.png"><img src="docs/images/example-rules-light.png" alt="A lista pesquisável das 42 regras" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-glass-dark.png"><img src="docs/images/example-glass-light.png" alt="Botões de vidro em um contêiner de efeito de vidro sobre um degradê azul" width="200"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-scene-dark.png"><img src="docs/images/example-scene-light.png" alt="O papel, as janelas, a orientação e a escala de exibição da cena de janela" width="200"></picture> |

As capturas de tela vêm do app em execução; `scripts/capture-example-screens.sh` as captura de novo.

## Documentação

Referência da API e artigos:

- [MigrationScanner no GitHub Pages](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/) — a referência da API
- [Primeiros passos](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/gettingstarted)
- [Referência de regras](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/rulereference) — todas as 42 regras com suas correções

## Guias

- [Adotando o ciclo de vida de cenas](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingthescenelifecycle) — manifesto, scene delegate, métodos que mudaram de lugar e substitutos para `UIScreen.main`
- [Adotando o Liquid Glass](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/adoptingliquidglass) — pare de recusá-lo, remova fundos personalizados, APIs renomeadas, vidro em controles personalizados
- [Executando no Xcode e no CI](https://muhittincamdali.github.io/iOS26-Migration-Guide/documentation/migrationscanner/runninginxcodeandci) — fase de build, anotações em pull requests, verificação de código, JSON

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| macOS (command line) | 14 |
| iOS (library) | 17 |
| Example app | iOS 26 |
| Ferramentas | Swift 6.2 (Xcode 26) |

## Arquitetura

- `Lexer` transforma um arquivo Swift em tokens e comentários; o conteúdo de strings e os comentários nunca viram tokens, mas o código interpolado vira.
- `BracketIndex` e `TokenIndex` indexam identificadores, pares de colchetes, rótulos de argumento e parâmetros de closures em uma única passada, de modo que cada matcher é linear em relação ao tamanho do arquivo.
- `RuleCatalog` guarda as regras; cada uma tem um matcher (sequência de tokens, acesso a membro, chamada ou declaração com rótulos de argumento, ou uma verificação de projeto), uma severidade e sua evidência no SDK.
- `ProjectFacts` coleta os pontos de entrada do app, os valores do Info.plist e os ajustes de build para as regras de projeto. `PropertyListGuard` recusa listas de propriedades com aninhamento profundo, cíclicas ou malformadas antes que o parser do sistema as leia.
- `ProjectScanner` percorre os arquivos com limites de tamanho e de quantidade e nunca segue links simbólicos; `ReportFormatter` grava os cinco formatos e faz o escape de caracteres de controle nos caminhos.
- `MigrationScanCLI` analisa e valida a linha de comando; o executável `migration-scan` apenas repassa a chamada a ele.

### Limitações conhecidas

- O scanner lê texto-fonte; ele não faz verificação de tipos. Uma regra como `uiapplication-key-window` corresponde a `UIApplication.shared.keyWindow`, não a um `keyWindow` alcançado por outra variável.
- As regras de projeto supõem um app por pasta escaneada: arquivos Info.plist e ajustes de build em qualquer lugar da pasta contam para o app encontrado ali.
- Ele sugere substituições e nunca reescreve o código.

## Roteiro

Novas regras acompanham novas versões do SDK; cada uma é adicionada com a declaração do SDK em que se baseia, um exemplo que ela deve relatar e outro que deve deixar em paz. Pedidos e relatos vão para as [issues](https://github.com/muhittincamdali/iOS26-Migration-Guide/issues).

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](CONTRIBUTING.md) e o [código de conduta](CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
