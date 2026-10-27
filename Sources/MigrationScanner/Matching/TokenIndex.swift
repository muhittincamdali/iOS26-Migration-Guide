/// Finds the places in one file where a ``Matcher`` applies.
///
/// Identifiers are indexed once, so each rule only looks at the positions of its anchor name, and
/// the bracket structure is computed once (``BracketIndex``), so reading an argument list or a
/// closure signature never rescans the file. A scan is linear in the size of the file.
struct TokenIndex {
    let tokens: [Token]
    let brackets: BracketIndex
    private let positions: [String: [Int]]

    init(tokens: [Token]) {
        self.tokens = tokens
        var positions: [String: [Int]] = [:]
        for (index, token) in tokens.enumerated() where token.kind == .identifier {
            positions[token.text, default: []].append(index)
        }
        self.positions = positions
        brackets = BracketIndex(tokens: tokens)
    }

    /// Whether any token is the identifier `name`.
    func contains(identifier name: String) -> Bool {
        positions[name] != nil
    }

    func positions(of name: String) -> [Int] {
        positions[name] ?? []
    }

    func token(at index: Int) -> Token? {
        index >= 0 && index < tokens.count ? tokens[index] : nil
    }

    // MARK: - Matching

    func locations(of matcher: Matcher) -> [SourceLocation] {
        switch matcher {
        case .sequences(let patterns):
            return patterns.flatMap(locations(of:))
        case .member(let name, let excludedBases):
            return positions(of: name).compactMap { position in
                guard token(at: position - 1)?.isPunctuation(".") == true else { return nil }
                if let base = token(at: position - 2), base.kind == .identifier {
                    let lowercasedBase = base.text.lowercased()
                    if excludedBases.contains(where: { lowercasedBase.hasSuffix($0.lowercased()) }) { return nil }
                }
                return tokens[position].location
            }
        case .call(let name, let member, let requirement):
            return positions(of: name).compactMap { position in
                if member, token(at: position - 1)?.isPunctuation(".") != true { return nil }
                guard let arguments = arguments(after: position, declaration: false),
                      requirement.accepts(arguments.labels) else { return nil }
                return tokens[position].location
            }
        case .declaration(let name, let expectedLabels):
            return positions(of: name).compactMap { position in
                guard token(at: position - 1)?.isIdentifier("func") == true,
                      let arguments = arguments(after: position, declaration: true) else { return nil }
                if let expectedLabels, arguments.labels != expectedLabels { return nil }
                return tokens[position].location
            }
        case .onChangeWithOneParameter:
            return positions(of: "onChange").compactMap(deprecatedOnChange(at:))
        case .any(let matchers):
            return matchers.flatMap(locations(of:))
        case .project:
            return []
        }
    }

    private func locations(of pattern: Pattern) -> [SourceLocation] {
        guard let anchor = pattern.anchor else { return [] }
        return positions(of: anchor.name).compactMap { position in
            let start = position - anchor.offset
            guard start >= 0, start + pattern.pieces.count <= tokens.count else { return nil }
            for (offset, piece) in pattern.pieces.enumerated() where !matches(piece, tokens[start + offset]) {
                return nil
            }
            return tokens[start + pattern.reportedPiece].location
        }
    }

    private func matches(_ piece: Piece, _ token: Token) -> Bool {
        switch piece {
        case .identifier(let name): token.isIdentifier(name)
        case .identifierEnding(let suffix): token.kind == .identifier && token.text.hasSuffix(suffix)
        case .punctuation(let mark): token.isPunctuation(mark)
        }
    }

    private func deprecatedOnChange(at position: Int) -> SourceLocation? {
        guard token(at: position - 1)?.isPunctuation(".") == true,
              let arguments = arguments(after: position, declaration: false),
              arguments.labels.first == "of" else { return nil }
        if arguments.labels.contains("perform") { return tokens[position].location }
        guard arguments.labels == ["of"],
              token(at: arguments.closingIndex + 1)?.isPunctuation("{") == true,
              closureParameterCount(openingBraceAt: arguments.closingIndex + 1) == 1 else { return nil }
        return tokens[position].location
    }
}
