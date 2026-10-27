/// One element of a token pattern.
enum Piece: Sendable, Hashable {
    case identifier(String)
    /// Any identifier whose text ends with the suffix, e.g. `preferredSearchBarPlacement`.
    case identifierEnding(String)
    case punctuation(String)
}

/// A token sequence and the piece whose position a finding reports.
struct Pattern: Sendable, Hashable {
    let pieces: [Piece]
    let reportedPiece: Int

    init(_ pieces: [Piece], reporting reportedPiece: Int = 0) {
        self.pieces = pieces
        self.reportedPiece = reportedPiece
    }

    /// The index of the first exact identifier: the scanner only tries positions where it occurs.
    var anchor: (offset: Int, name: String)? {
        for (offset, piece) in pieces.enumerated() {
            if case .identifier(let name) = piece { return (offset, name) }
        }
        return nil
    }
}

/// Which argument labels a call must have. Unlabeled arguments are written `_`; trailing closures
/// do not count.
enum LabelRequirement: Sendable, Hashable {
    case any
    case exactly([String])
    case startingWith([String])
    case containing(String)

    func accepts(_ labels: [String]) -> Bool {
        switch self {
        case .any: true
        case .exactly(let expected): labels == expected
        case .startingWith(let prefix): labels.starts(with: prefix)
        case .containing(let label): labels.contains(label)
        }
    }
}

/// The project-level checks, which read Info.plist files, build settings and app entry points.
enum ProjectCheck: Sendable, Hashable {
    case sceneManifestMissing
    case sceneConfigurationMissing
    case designCompatibilityMode
}

/// How a rule recognizes the code it reports.
enum Matcher: Sendable, Hashable {
    /// Any of the token sequences.
    case sequences([Pattern])
    /// `.name` where the identifier before the dot does not end with any of `excludedBases`
    /// (compared without case), so `["Geometry"]` skips `effectiveGeometry.interfaceOrientation`.
    case member(String, excludedBases: [String])
    /// A call `name(…)` (or `.name(…)` when `member` is true) whose labels meet the requirement.
    case call(String, member: Bool, labels: LabelRequirement)
    /// A method declaration `func name(…)`; with `labels`, its argument labels must match exactly.
    case declaration(String, labels: [String]?)
    /// `onChange(of:)` with an action closure that takes one parameter (the iOS 17 deprecation).
    case onChangeWithOneParameter
    /// Any of the matchers.
    case any([Matcher])
    /// Evaluated over the whole project, not per file.
    case project(ProjectCheck)

    /// A sequence of one dotted path, e.g. `path("UIScreen", "main")` for `UIScreen.main`.
    static func path(_ components: String...) -> Matcher {
        var pieces: [Piece] = []
        for (index, component) in components.enumerated() {
            if index > 0 { pieces.append(.punctuation(".")) }
            pieces.append(.identifier(component))
        }
        return .sequences([Pattern(pieces, reporting: pieces.count - 1)])
    }
}
