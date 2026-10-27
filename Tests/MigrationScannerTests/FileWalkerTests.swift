import Foundation
import Testing
@testable import MigrationScanner

@Suite("Files and limits")
struct FileWalkerTests {
    @Test("Build output, dependencies and hidden folders are skipped")
    func excludedDirectories() throws {
        let project = try TemporaryDirectory()
        try project.write("Sources/App.swift", "let s = UIScreen.main")
        for folder in [".build", "Pods", "DerivedData", "Carthage", ".hidden", "node_modules"] {
            try project.write("\(folder)/Vendor.swift", "let s = UIScreen.main")
        }
        let report = project.scan()
        #expect(report.findings.map(\.file) == [project.url.path + "/Sources/App.swift"])
        #expect(report.filesScanned == 1)
    }

    @Test("Extra excluded directory names apply at any depth")
    func customExclusion() throws {
        let project = try TemporaryDirectory()
        try project.write("App/Generated/Strings.swift", "let s = UIScreen.main")
        var configuration = ScanConfiguration()
        configuration.excludedDirectoryNames.insert("Generated")
        #expect(project.scan(configuration).findings.isEmpty)
    }

    @Test("A symbolic link back to a parent folder is not followed")
    func symbolicLinkLoop() throws {
        let project = try TemporaryDirectory()
        try project.write("App/App.swift", "let s = UIScreen.main")
        try FileManager.default.createSymbolicLink(
            at: project.url.appendingPathComponent("App/Loop"), withDestinationURL: project.url)
        try FileManager.default.createSymbolicLink(
            at: project.url.appendingPathComponent("App/Alias.swift"),
            withDestinationURL: project.url.appendingPathComponent("App/App.swift"))
        let report = project.scan()
        #expect(report.findings.count == 1)
        #expect(report.filesScanned == 1)
    }

    @Test("The file limit stops the walk with a notice")
    func fileLimit() throws {
        let project = try TemporaryDirectory()
        for index in 0..<5 { try project.write("App/File\(index).swift", "let s = UIScreen.main") }
        let report = project.scan(ScanConfiguration(maximumFileCount: 3))
        #expect(report.filesScanned == 3)
        #expect(report.notices.map(\.kind) == [.fileLimitReached])
        #expect(project.scan(ScanConfiguration(maximumFileCount: 5)).notices.isEmpty)
    }

    @Test("Files over the size limit are skipped with a notice")
    func sizeLimit() throws {
        let project = try TemporaryDirectory()
        try project.write("App/Big.swift", "let s = UIScreen.main // " + String(repeating: "x", count: 200))
        try project.write("App/Small.swift", "let s = UIScreen.main")
        let report = project.scan(ScanConfiguration(maximumFileSize: 100))
        #expect(report.findings.map { URL(fileURLWithPath: $0.file).lastPathComponent } == ["Small.swift"])
        #expect(report.notices.map(\.kind) == [.fileTooLarge])
        #expect(report.notices.first?.file?.hasSuffix("Big.swift") == true)
    }

    @Test("The largest size limit does not overflow")
    func largestSizeLimit() throws {
        let project = try TemporaryDirectory()
        try project.write("App/App.swift", "let s = UIScreen.main")
        #expect(project.scan(ScanConfiguration(maximumFileSize: .max)).findings.count == 1)
    }

    @Test("Limits below 1 are raised to 1")
    func limitsAreClamped() {
        var configuration = ScanConfiguration(maximumFileSize: 0, maximumFileCount: -5)
        #expect(configuration.maximumFileSize == 1)
        #expect(configuration.maximumFileCount == 1)
        configuration.maximumFileSize = -1
        #expect(configuration.maximumFileSize == 1)
    }

    @Test("A missing path is reported; single files are scanned directly")
    func explicitPaths() throws {
        let project = try TemporaryDirectory()
        let file = try project.write("App.swift", "let s = UIScreen.main")
        let missing = project.url.appendingPathComponent("Missing")
        let report = ProjectScanner().scan(paths: [file, missing])
        #expect(report.findings.map(\.file) == [file.path])
        #expect(report.notices.map(\.kind) == [.unreadable])
    }

    @Test("Paths are reported under the path the scan was given")
    func relativeDisplayPaths() throws {
        let project = try TemporaryDirectory()
        try project.write("Sources/App.swift", "let s = UIScreen.main")
        let relative = URL(fileURLWithPath: "Sources", relativeTo: project.url)
        #expect(ProjectScanner().scan(paths: [relative]).findings.map(\.file) == ["Sources/App.swift"])
    }

    @Test("Files that are not UTF-8 are read with replacement characters, not rejected")
    func invalidUTF8() throws {
        let project = try TemporaryDirectory()
        try project.write("App.swift", Data([0xFF, 0xFE]) + Data(" let s = UIScreen.main".utf8))
        #expect(project.scan().findings.map(\.ruleID) == ["uiscreen-main"])
    }
}
