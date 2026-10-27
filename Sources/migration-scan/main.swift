import Foundation
import MigrationScanCLI

let code = MigrationScanCommand.run(
    Array(CommandLine.arguments.dropFirst()),
    standardOutput: { FileHandle.standardOutput.write(Data($0.utf8)) },
    standardError: { FileHandle.standardError.write(Data($0.utf8)) }
)
exit(code.rawValue)
