// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "iOS26-Migration-Guide",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MigrationScanner", targets: ["MigrationScanner"]),
        .executable(name: "migration-scan", targets: ["migration-scan"])
    ],
    targets: [
        .target(name: "MigrationScanner"),
        .target(name: "MigrationScanCLI", dependencies: ["MigrationScanner"]),
        .executableTarget(name: "migration-scan", dependencies: ["MigrationScanCLI"]),
        .testTarget(
            name: "MigrationScannerTests",
            dependencies: ["MigrationScanner", "MigrationScanCLI"],
            resources: [.copy("Fixtures")]
        )
    ]
)
