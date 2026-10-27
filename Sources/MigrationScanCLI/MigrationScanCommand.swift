import Foundation
import MigrationScanner

/// Runs `migration-scan`. The executable only forwards its arguments and exit code, so every
/// path through the command is covered by tests.
public enum MigrationScanCommand {
    /// Exit codes.
    public enum ExitCode: Int32, Sendable {
        /// No finding at or above the `--fail-on` severity.
        case success = 0
        /// At least one finding at or above the `--fail-on` severity.
        case findings = 1
        /// The command line is wrong, or a path does not exist.
        case usage = 2
    }

    public static func run(
        _ arguments: [String],
        standardOutput: (String) -> Void,
        standardError: (String) -> Void
    ) -> ExitCode {
        let invocation: Invocation
        do {
            invocation = try CommandLineParser.parse(arguments)
        } catch {
            standardError("migration-scan: \(error.description)\n")
            return .usage
        }
        switch invocation {
        case .help:
            standardOutput(HelpText.usage)
        case .version:
            standardOutput("migration-scan \(ReportFormatter.toolVersion)\n")
        case .listRules(let format):
            standardOutput(format == .json ? RuleListing.json() : RuleListing.text())
        case .explain(let id):
            if let rule = RuleCatalog.rule(id: id) { standardOutput(RuleListing.explanation(of: rule)) }
        case .scan(let options):
            return scan(options, standardOutput: standardOutput, standardError: standardError)
        }
        return .success
    }

    private static func scan(
        _ options: ScanOptions,
        standardOutput: (String) -> Void,
        standardError: (String) -> Void
    ) -> ExitCode {
        let missing = options.paths.filter { !FileManager.default.fileExists(atPath: $0) }
        guard missing.isEmpty else {
            for path in missing {
                standardError("migration-scan: no such file or directory: \(OutputSanitizer.sanitize(path))\n")
            }
            return .usage
        }
        let urls = options.paths.map { URL(fileURLWithPath: $0) }
        let report = ProjectScanner(configuration: options.configuration).scan(paths: urls)
        standardOutput(ReportFormatter.format(report, as: options.format))
        guard let threshold = options.failOn else { return .success }
        return report.hasFindings(atLeast: threshold) ? .findings : .success
    }
}
