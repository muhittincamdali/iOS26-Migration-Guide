// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "iOS26-Migration-Guide",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "MigrationScanner", targets: ["MigrationScanner"])
    ],
    targets: [
        .target(name: "MigrationScanner"),
        .testTarget(
            name: "MigrationScannerTests",
            dependencies: ["MigrationScanner"],
            resources: [.copy("Fixtures")]
        )
    ]
)
