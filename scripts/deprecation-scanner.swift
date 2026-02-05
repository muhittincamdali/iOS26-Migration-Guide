#!/usr/bin/env swift

// MARK: - iOS 26 Deprecation Scanner Tool
// Scans Swift and Objective-C source files for deprecated APIs
// Usage: swift deprecation-scanner.swift /path/to/project

import Foundation

// MARK: - Deprecated API Patterns

struct DeprecatedAPI {
    let pattern: String
    let severity: Severity
    let message: String
    let replacement: String
    let targetRemoval: String
    
    enum Severity: String, CustomStringConvertible {
        case error = "🔴 ERROR"
        case warning = "🟡 WARNING"
        case info = "🔵 INFO"
        
        var description: String { rawValue }
    }
}

let deprecatedAPIs: [DeprecatedAPI] = [
    // MARK: - Removed in iOS 26 (Compile Errors)
    DeprecatedAPI(
        pattern: "UITableView\\(",
        severity: .error,
        message: "UITableView is removed in iOS 26",
        replacement: "UICollectionView with UICollectionLayoutListConfiguration",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "UIScreen\\.main",
        severity: .error,
        message: "UIScreen.main is removed in iOS 26",
        replacement: "view.window?.windowScene?.screen",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "UIWebView",
        severity: .error,
        message: "UIWebView is removed in iOS 26",
        replacement: "WKWebView",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "UIAlertView",
        severity: .error,
        message: "UIAlertView is removed in iOS 26",
        replacement: "UIAlertController",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "AddressBook",
        severity: .error,
        message: "AddressBook framework is removed in iOS 26",
        replacement: "Contacts framework",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "UIApplication\\.shared\\.keyWindow",
        severity: .error,
        message: "keyWindow is removed in iOS 26",
        replacement: "UIApplication.shared.connectedScenes.compactMap { $0.keyWindow }",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "\\.navigationBarTitle\\(",
        severity: .error,
        message: ".navigationBarTitle is removed in iOS 26",
        replacement: ".navigationTitle()",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "NavigationView\\s*\\{",
        severity: .error,
        message: "NavigationView is removed in iOS 26",
        replacement: "NavigationStack or NavigationSplitView",
        targetRemoval: "iOS 26"
    ),
    
    // MARK: - Deprecated (Warnings)
    DeprecatedAPI(
        pattern: "@StateObject",
        severity: .warning,
        message: "@StateObject is deprecated in iOS 26",
        replacement: "@State with @Observable class",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "@ObservedObject",
        severity: .warning,
        message: "@ObservedObject is deprecated in iOS 26",
        replacement: "Direct observation with @Observable",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "@EnvironmentObject",
        severity: .warning,
        message: "@EnvironmentObject is deprecated in iOS 26",
        replacement: "@Environment(Type.self)",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "@Published",
        severity: .warning,
        message: "@Published is deprecated in iOS 26",
        replacement: "@Observable macro properties",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "ObservableObject",
        severity: .warning,
        message: "ObservableObject protocol is deprecated in iOS 26",
        replacement: "@Observable macro",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "CADisplayLink",
        severity: .warning,
        message: "CADisplayLink is deprecated in iOS 26",
        replacement: "UIUpdateLink",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "UIView\\.animate\\(withDuration:",
        severity: .warning,
        message: "UIView.animate(withDuration:) is deprecated in iOS 26",
        replacement: "UIView.animate(springDuration:bounce:)",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "\\.ultraThinMaterial",
        severity: .info,
        message: "Material modifiers should migrate to Liquid Glass",
        replacement: ".glassEffect(.subtle)",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "\\.thinMaterial",
        severity: .info,
        message: "Material modifiers should migrate to Liquid Glass",
        replacement: ".glassEffect(.light)",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "\\.regularMaterial",
        severity: .info,
        message: "Material modifiers should migrate to Liquid Glass",
        replacement: ".glassEffect()",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "\\.thickMaterial",
        severity: .info,
        message: "Material modifiers should migrate to Liquid Glass",
        replacement: ".glassEffect(.prominent)",
        targetRemoval: "iOS 28"
    ),
    DeprecatedAPI(
        pattern: "GeometryReader\\s*\\{",
        severity: .info,
        message: "Consider using Layout protocol for many GeometryReader use cases",
        replacement: "Layout protocol or containerRelativeFrame",
        targetRemoval: "Recommended migration"
    ),
    DeprecatedAPI(
        pattern: "AnyView\\(",
        severity: .info,
        message: "AnyView causes performance issues in LazyVStack/LazyHStack",
        replacement: "Use concrete types with @ViewBuilder",
        targetRemoval: "Performance improvement"
    ),
    DeprecatedAPI(
        pattern: "\\.sheet\\(isPresented:",
        severity: .info,
        message: "Consider unified presentation API",
        replacement: ".presentation(isPresented:style:.sheet)",
        targetRemoval: "iOS 27"
    ),
    DeprecatedAPI(
        pattern: "\\.fullScreenCover\\(",
        severity: .info,
        message: "Consider unified presentation API",
        replacement: ".presentation(isPresented:style:.fullScreen)",
        targetRemoval: "iOS 27"
    ),
    
    // MARK: - Concurrency Patterns
    DeprecatedAPI(
        pattern: "@escaping.*\\) -> Void",
        severity: .info,
        message: "Completion handler pattern should migrate to async/await",
        replacement: "async throws -> ReturnType",
        targetRemoval: "Swift 6 best practice"
    ),
    DeprecatedAPI(
        pattern: "DispatchQueue\\.main\\.async",
        severity: .info,
        message: "Consider MainActor for UI updates",
        replacement: "await MainActor.run { } or @MainActor",
        targetRemoval: "Swift 6 best practice"
    ),
    DeprecatedAPI(
        pattern: "DispatchQueue\\.global",
        severity: .info,
        message: "Consider Task.detached for background work",
        replacement: "Task.detached(priority:) { }",
        targetRemoval: "Swift 6 best practice"
    ),
    
    // MARK: - UIKit Patterns
    DeprecatedAPI(
        pattern: "UINavigationBar\\.appearance\\(\\)",
        severity: .error,
        message: "Global appearance proxy is removed in iOS 26",
        replacement: "Per-instance UINavigationBarAppearance",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "UITabBar\\.appearance\\(\\)",
        severity: .error,
        message: "Global appearance proxy is removed in iOS 26",
        replacement: "Per-instance UITabBarAppearance",
        targetRemoval: "iOS 26"
    ),
    DeprecatedAPI(
        pattern: "layoutSubviews\\(\\)",
        severity: .warning,
        message: "layoutSubviews() override is deprecated",
        replacement: "updateLayout(with: UILayoutContext)",
        targetRemoval: "iOS 28"
    ),
]

// MARK: - Scanner Implementation

struct ScanResult {
    let file: String
    let line: Int
    let column: Int
    let api: DeprecatedAPI
    let matchedText: String
}

class DeprecationScanner {
    var results: [ScanResult] = []
    var fileCount = 0
    var errorCount = 0
    var warningCount = 0
    var infoCount = 0
    
    func scan(directory: String) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: directory)
        
        while let file = enumerator?.nextObject() as? String {
            if file.hasSuffix(".swift") || file.hasSuffix(".m") || file.hasSuffix(".h") {
                let fullPath = (directory as NSString).appendingPathComponent(file)
                scanFile(fullPath)
            }
        }
    }
    
    func scanFile(_ path: String) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        fileCount += 1
        
        let lines = content.components(separatedBy: .newlines)
        
        for (lineNumber, line) in lines.enumerated() {
            for api in deprecatedAPIs {
                if let regex = try? NSRegularExpression(pattern: api.pattern, options: []),
                   let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
                    let matchedText = String(line[Range(match.range, in: line)!])
                    let result = ScanResult(
                        file: path,
                        line: lineNumber + 1,
                        column: match.range.location + 1,
                        api: api,
                        matchedText: matchedText
                    )
                    results.append(result)
                    
                    switch api.severity {
                    case .error: errorCount += 1
                    case .warning: warningCount += 1
                    case .info: infoCount += 1
                    }
                }
            }
        }
    }
    
    func printResults() {
        print("""
        
        ╔══════════════════════════════════════════════════════════════╗
        ║           iOS 26 DEPRECATION SCANNER RESULTS                 ║
        ╚══════════════════════════════════════════════════════════════╝
        
        📁 Files Scanned: \(fileCount)
        🔴 Errors (will not compile): \(errorCount)
        🟡 Warnings (deprecated): \(warningCount)
        🔵 Info (recommendations): \(infoCount)
        
        """)
        
        if results.isEmpty {
            print("✅ No deprecated APIs found! Your code is iOS 26 ready.")
            return
        }
        
        // Group by severity
        let errors = results.filter { $0.api.severity == .error }
        let warnings = results.filter { $0.api.severity == .warning }
        let info = results.filter { $0.api.severity == .info }
        
        if !errors.isEmpty {
            print("═══════════════════════════════════════════════════════════════")
            print("🔴 ERRORS - These will not compile in iOS 26")
            print("═══════════════════════════════════════════════════════════════")
            for result in errors {
                printResult(result)
            }
        }
        
        if !warnings.isEmpty {
            print("\n═══════════════════════════════════════════════════════════════")
            print("🟡 WARNINGS - Deprecated, plan migration")
            print("═══════════════════════════════════════════════════════════════")
            for result in warnings {
                printResult(result)
            }
        }
        
        if !info.isEmpty {
            print("\n═══════════════════════════════════════════════════════════════")
            print("🔵 INFO - Recommended improvements")
            print("═══════════════════════════════════════════════════════════════")
            for result in info {
                printResult(result)
            }
        }
        
        print("""
        
        ═══════════════════════════════════════════════════════════════
        📋 SUMMARY
        ═══════════════════════════════════════════════════════════════
        
        Migration Priority:
        1. Fix all 🔴 ERRORS first - code will not compile
        2. Address 🟡 WARNINGS before target removal dates
        3. Consider 🔵 INFO for best practices
        
        Estimated effort:
        - \(errorCount) errors × ~30 min each = ~\(errorCount * 30) minutes
        - \(warningCount) warnings × ~15 min each = ~\(warningCount * 15) minutes
        
        Total estimated migration time: ~\((errorCount * 30 + warningCount * 15) / 60) hours
        
        For migration guidance, visit:
        https://github.com/muhittincamdali/iOS26-Migration-Guide
        
        """)
    }
    
    func printResult(_ result: ScanResult) {
        let relativePath = result.file.components(separatedBy: "/").suffix(3).joined(separator: "/")
        print("""
        
        \(result.api.severity) \(result.api.message)
        📍 \(relativePath):\(result.line):\(result.column)
        ❌ Found: \(result.matchedText)
        ✅ Replace with: \(result.api.replacement)
        ⏰ Target removal: \(result.api.targetRemoval)
        """)
    }
    
    func generateReport(outputPath: String) {
        var report = """
        # iOS 26 Deprecation Scanner Report
        
        Generated: \(ISO8601DateFormatter().string(from: Date()))
        
        ## Summary
        
        | Metric | Count |
        |--------|-------|
        | Files Scanned | \(fileCount) |
        | Errors | \(errorCount) |
        | Warnings | \(warningCount) |
        | Info | \(infoCount) |
        
        ## Errors (Will Not Compile)
        
        """
        
        for result in results.filter({ $0.api.severity == .error }) {
            report += """
            
            ### \(result.api.message)
            
            - **File**: `\(result.file)`
            - **Line**: \(result.line)
            - **Found**: `\(result.matchedText)`
            - **Replace with**: `\(result.api.replacement)`
            
            """
        }
        
        report += "\n## Warnings (Deprecated)\n"
        
        for result in results.filter({ $0.api.severity == .warning }) {
            report += """
            
            ### \(result.api.message)
            
            - **File**: `\(result.file)`
            - **Line**: \(result.line)
            - **Found**: `\(result.matchedText)`
            - **Replace with**: `\(result.api.replacement)`
            - **Target removal**: \(result.api.targetRemoval)
            
            """
        }
        
        try? report.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print("📝 Report saved to: \(outputPath)")
    }
}

// MARK: - Main Execution

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("""
    iOS 26 Deprecation Scanner
    
    Usage: swift deprecation-scanner.swift <project-path> [--report <output-path>]
    
    Examples:
      swift deprecation-scanner.swift ./MyApp
      swift deprecation-scanner.swift ./MyApp --report ./deprecation-report.md
    
    Options:
      --report <path>  Generate markdown report at specified path
    """)
    exit(1)
}

let projectPath = arguments[1]
let scanner = DeprecationScanner()

print("🔍 Scanning \(projectPath) for deprecated iOS 26 APIs...")
scanner.scan(directory: projectPath)
scanner.printResults()

if let reportIndex = arguments.firstIndex(of: "--report"),
   arguments.count > reportIndex + 1 {
    let reportPath = arguments[reportIndex + 1]
    scanner.generateReport(outputPath: reportPath)
}

exit(scanner.errorCount > 0 ? 1 : 0)
