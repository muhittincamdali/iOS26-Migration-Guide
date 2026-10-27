/// The tokens and comments of one Swift source file.
struct LexedSource: Sendable {
    let tokens: [Token]
    let comments: [Comment]
}

/// A small Swift lexer that is just precise enough for the rule matchers.
///
/// It separates code from comments (nested `/* */` included) and from string literals (single
/// line, multi-line, raw `#"…"#` and extended regex `#/…/#` literals). Code inside a string
/// interpolation, `"\(UIScreen.main.scale)"`, is lexed as code, because it is code. Unterminated
/// literals and comments end at the end of the line or file instead of failing: the scanner sees
/// files that do not compile yet. Work is linear in the length of the input.
struct Lexer {
    private enum Context {
        /// Ordinary code; `parenthesisDepth` is non-nil inside a string interpolation.
        case code(parenthesisDepth: Int?)
        case string(hashes: Int, multiline: Bool)
        case regex(hashes: Int)
    }

    private let scalars: [Unicode.Scalar]
    private var index = 0
    private var line = 1
    private var column = 1
    private var lastTokenLine = 0
    private var stack: [Context] = [.code(parenthesisDepth: nil)]
    private var tokens: [Token] = []
    private var comments: [Comment] = []

    private init(_ source: String) {
        scalars = Array(source.unicodeScalars)
    }

    static func lex(_ source: String) -> LexedSource {
        var lexer = Lexer(source)
        lexer.run()
        return LexedSource(tokens: lexer.tokens, comments: lexer.comments)
    }

    private mutating func run() {
        while index < scalars.count {
            switch stack[stack.count - 1] {
            case .code(let depth): lexCode(interpolationDepth: depth)
            case .string(let hashes, let multiline): lexString(hashes: hashes, multiline: multiline)
            case .regex(let hashes): lexRegex(hashes: hashes)
            }
        }
    }

    // MARK: - Scalars

    private func scalar(at offset: Int) -> Unicode.Scalar? {
        let position = index + offset
        return position < scalars.count ? scalars[position] : nil
    }

    private var location: SourceLocation { SourceLocation(line: line, column: column) }

    private static func isNewline(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "\n" || scalar == "\r"
    }

    /// Moves past one scalar, treating `\r\n` as a single line break.
    private mutating func advance() {
        let current = scalars[index]
        index += 1
        if current == "\r", index < scalars.count, scalars[index] == "\n" {
            index += 1
        }
        if Self.isNewline(current) {
            line += 1
            column = 1
        } else {
            column += 1
        }
    }

    private mutating func advance(by count: Int) {
        for _ in 0..<count where index < scalars.count { advance() }
    }

    /// The number of `#` characters starting `offset` scalars ahead.
    private func hashCount(from offset: Int) -> Int {
        var count = 0
        while scalar(at: offset + count) == "#" { count += 1 }
        return count
    }

    private mutating func emit(_ kind: Token.Kind, _ text: String, at start: SourceLocation) {
        tokens.append(Token(kind: kind, text: text, location: start))
        lastTokenLine = start.line
    }

    // MARK: - Code

    private mutating func lexCode(interpolationDepth: Int?) {
        let current = scalars[index]
        let start = location
        if Self.isNewline(current) || current.properties.isWhitespace {
            advance()
        } else if current == "/", scalar(at: 1) == "/" {
            lexLineComment()
        } else if current == "/", scalar(at: 1) == "*" {
            lexBlockComment()
        } else if current == "#" {
            lexHash(at: start)
        } else if current == "\"" {
            beginString(hashes: 0, at: start)
        } else if current == "`" {
            lexBacktickIdentifier(at: start)
        } else if current == "_" || current == "$" || current.properties.isXIDStart {
            emit(.identifier, readWhile { $0 == "$" || $0.properties.isXIDContinue }, at: start)
        } else if current.properties.numericType == .decimal, current.isASCII {
            lexNumber(at: start)
        } else {
            lexPunctuation(current, interpolationDepth: interpolationDepth, at: start)
        }
    }

    private mutating func readWhile(_ predicate: (Unicode.Scalar) -> Bool) -> String {
        var text = String.UnicodeScalarView()
        while index < scalars.count, predicate(scalars[index]) {
            text.append(scalars[index])
            advance()
        }
        return String(text)
    }

    private mutating func lexNumber(at start: SourceLocation) {
        var text = String.UnicodeScalarView()
        while let current = scalar(at: 0) {
            let isDecimalPoint = current == "." && (scalar(at: 1)?.properties.numericType == .decimal)
            guard current.properties.isXIDContinue || isDecimalPoint else { break }
            text.append(current)
            advance()
        }
        emit(.number, String(text), at: start)
    }

    private mutating func lexBacktickIdentifier(at start: SourceLocation) {
        advance()
        let name = readWhile { $0 != "`" && !Self.isNewline($0) }
        if scalar(at: 0) == "`" { advance() }
        emit(.identifier, name, at: start)
    }

    private mutating func lexHash(at start: SourceLocation) {
        let hashes = hashCount(from: 0)
        switch scalar(at: hashes) {
        case "\"":
            beginString(hashes: hashes, at: start)
        case "/":
            advance(by: hashes + 1)
            emit(.string, "", at: start)
            stack.append(.regex(hashes: hashes))
        default:
            advance()
            emit(.punctuation, "#", at: start)
        }
    }

    private mutating func lexPunctuation(
        _ current: Unicode.Scalar,
        interpolationDepth: Int?,
        at start: SourceLocation
    ) {
        if let depth = interpolationDepth {
            if current == "(" {
                stack[stack.count - 1] = .code(parenthesisDepth: depth + 1)
            } else if current == ")" {
                if depth == 0 {
                    // The parenthesis that closes `\(`: back to the string.
                    advance()
                    stack.removeLast()
                    return
                }
                stack[stack.count - 1] = .code(parenthesisDepth: depth - 1)
            }
        }
        advance()
        emit(.punctuation, String(current), at: start)
    }

    // MARK: - Comments

    private mutating func lexLineComment() {
        let startLine = line
        let followsCode = lastTokenLine == startLine
        advance(by: 2)
        let text = readWhile { !Self.isNewline($0) }
        comments.append(Comment(line: startLine, text: text, followsCode: followsCode))
    }

    private mutating func lexBlockComment() {
        let startLine = line
        let followsCode = lastTokenLine == startLine
        advance(by: 2)
        var depth = 1
        var text = String.UnicodeScalarView()
        while index < scalars.count {
            let opens = scalars[index] == "/" && scalar(at: 1) == "*"
            let closes = scalars[index] == "*" && scalar(at: 1) == "/"
            guard opens || closes else {
                text.append(scalars[index])
                advance()
                continue
            }
            // Both markers are two scalars long; consuming them whole keeps `/*/` and `*/*`
            // from being read as two markers.
            depth += opens ? 1 : -1
            if depth == 0 {
                advance(by: 2)
                break
            }
            text.append(contentsOf: scalars[index...(index + 1)])
            advance(by: 2)
        }
        comments.append(Comment(line: startLine, text: String(text), followsCode: followsCode))
    }

    // MARK: - String and regex literals

    private mutating func beginString(hashes: Int, at start: SourceLocation) {
        let multiline = scalar(at: hashes + 1) == "\"" && scalar(at: hashes + 2) == "\""
        advance(by: hashes + (multiline ? 3 : 1))
        emit(.string, "", at: start)
        stack.append(.string(hashes: hashes, multiline: multiline))
    }

    private func hasHashes(_ count: Int, from offset: Int) -> Bool {
        (0..<count).allSatisfy { scalar(at: offset + $0) == "#" }
    }

    private mutating func lexString(hashes: Int, multiline: Bool) {
        let current = scalars[index]
        if current == "\\", hasHashes(hashes, from: 1) {
            if scalar(at: 1 + hashes) == "(" {
                advance(by: hashes + 2)
                stack.append(.code(parenthesisDepth: 0))
            } else {
                // An escape such as \" or \#n: skip the backslash, the hashes and one scalar,
                // unless that scalar ends a single-line literal that was never closed.
                advance(by: hashes + 1)
                if let next = scalar(at: 0), multiline || !Self.isNewline(next) { advance() }
            }
        } else if current == "\"" {
            let quotes = multiline ? 3 : 1
            let closes = (0..<quotes).allSatisfy { scalar(at: $0) == "\"" } && hasHashes(hashes, from: quotes)
            if closes { stack.removeLast() }
            advance(by: closes ? quotes + hashes : 1)
        } else if Self.isNewline(current), !multiline {
            // A single-line literal cannot span lines: treat it as closed so the next line is code.
            stack.removeLast()
        } else {
            advance()
        }
    }

    private mutating func lexRegex(hashes: Int) {
        if scalars[index] == "/", hasHashes(hashes, from: 1) {
            advance(by: hashes + 1)
            stack.removeLast()
        } else {
            advance()
        }
    }
}
