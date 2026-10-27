/// A 1-based position in a source file. `column` counts Unicode scalars, so a line with an emoji
/// before the match reports the same column in every output format.
public struct SourceLocation: Sendable, Hashable, Codable, Comparable {
    public let line: Int
    public let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }

    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        (lhs.line, lhs.column) < (rhs.line, rhs.column)
    }
}

/// A piece of Swift code as the matchers see it. Comments and string contents never become
/// tokens, so a rule cannot fire on `// UIScreen.main` or on `"UIScreen.main"`.
struct Token: Sendable, Equatable {
    enum Kind: Sendable, Equatable {
        case identifier
        case number
        case punctuation
        /// A whole string literal (or the part of it before an interpolation). Its text is empty.
        case string
    }

    let kind: Kind
    let text: String
    let location: SourceLocation

    func isIdentifier(_ name: String) -> Bool { kind == .identifier && text == name }
    func isPunctuation(_ mark: String) -> Bool { kind == .punctuation && text == mark }
}

/// A comment with the line it starts on; suppression directives are read from these.
struct Comment: Sendable, Equatable {
    let line: Int
    let text: String
    /// Whether code precedes the comment on its first line.
    let followsCode: Bool
}
