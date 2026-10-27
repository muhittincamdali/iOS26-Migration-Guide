import Foundation

/// A file the scanner reads, and the path it reports for it.
struct ScanFile: Equatable {
    enum Kind: Equatable {
        case swiftSource
        case propertyList
        case buildSettings
    }

    let url: URL
    let displayPath: String
    let kind: Kind

    static func kind(forName name: String) -> Kind? {
        if name.hasSuffix(".swift") { return .swiftSource }
        if ProjectFacts.isInfoPropertyList(name) { return .propertyList }
        if ProjectFacts.isBuildSettingsFile(name) { return .buildSettings }
        return nil
    }
}

/// Lists the files under the scanned paths.
///
/// Symbolic links inside a directory are never followed, so a link back to a parent cannot make
/// the walk loop, and the walk stops at ``ScanConfiguration/maximumFileCount`` files. Hidden
/// directories and the configured build and dependency folders are not entered.
struct FileWalker {
    let configuration: ScanConfiguration

    func collect(_ roots: [URL]) -> (files: [ScanFile], notices: [Notice]) {
        var files: [ScanFile] = []
        var notices: [Notice] = []
        for root in roots where files.count <= configuration.maximumFileCount {
            let display = Self.displayPath(of: root)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDirectory) else {
                notices.append(Notice(kind: .unreadable, file: display))
                continue
            }
            if isDirectory.boolValue {
                walk(root, display: display, into: &files)
            } else if let kind = ScanFile.kind(forName: root.lastPathComponent) {
                files.append(ScanFile(url: root, displayPath: display, kind: kind))
            }
        }
        if files.count > configuration.maximumFileCount {
            files.removeLast(files.count - configuration.maximumFileCount)
            notices.append(Notice(kind: .fileLimitReached, file: nil))
        }
        return (files, notices)
    }

    /// Adds the files of one directory, one past the limit at most so the caller can tell that
    /// files were left out.
    private func walk(_ root: URL, display: String, into files: inout [ScanFile]) {
        let keys: [URLResourceKey] = [.isDirectoryKey, .isSymbolicLinkKey, .isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles],
            errorHandler: { _, _ in true }
        ) else { return }
        let rootPath = root.standardizedFileURL.path
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: Set(keys)) else { continue }
            if values.isSymbolicLink == true {
                if values.isDirectory == true { enumerator.skipDescendants() }
                continue
            }
            if values.isDirectory == true {
                if configuration.excludedDirectoryNames.contains(url.lastPathComponent) { enumerator.skipDescendants() }
                continue
            }
            guard values.isRegularFile == true, let kind = ScanFile.kind(forName: url.lastPathComponent) else { continue }
            files.append(ScanFile(url: url, displayPath: Self.join(display, Self.relativePath(of: url, under: rootPath)), kind: kind))
            if files.count > configuration.maximumFileCount { return }
        }
    }

    private static func displayPath(of url: URL) -> String {
        var path = url.relativeString.hasPrefix("file://") ? url.path : url.relativePath
        while path.count > 1, path.hasSuffix("/") { path.removeLast() }
        return path
    }

    private static func relativePath(of url: URL, under rootPath: String) -> String {
        let path = url.standardizedFileURL.path
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        return path.hasPrefix(prefix) ? String(path.dropFirst(prefix.count)) : url.lastPathComponent
    }

    private static func join(_ directory: String, _ relative: String) -> String {
        directory.hasSuffix("/") ? directory + relative : directory + "/" + relative
    }
}
