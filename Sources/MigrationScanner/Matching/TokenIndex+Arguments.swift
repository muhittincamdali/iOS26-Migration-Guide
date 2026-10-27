/// The argument labels of a call or a declaration, and where its parameter list ends.
struct ArgumentList: Equatable {
    let labels: [String]
    let closingIndex: Int
}

extension TokenIndex {
    /// Words that start a statement, never a closure parameter list.
    private static let statementKeywords: Set<String> = [
        "for", "let", "var", "if", "guard", "return", "switch", "case", "while", "repeat", "try", "await", "do"
    ]
    /// Tokens that may appear in a closure signature such as `(old: Int, new: Int) throws -> Void`.
    private static let signatureMarks: Set<String> = [",", "(", ")", ":", ".", "<", ">", "?", "!", "-", "@", "[", "]"]

    /// Reads the parenthesized list that follows the name at `position`.
    ///
    /// For a call, an argument's label is the identifier before its colon, or `_`. For a
    /// declaration, it is the first word of each parameter (`_` in `_ app: UIApplication`).
    /// Commas inside nested brackets, and in a declaration inside generic angle brackets, do not
    /// start a new argument. Returns `nil` when the next token is not `(` or the list never closes.
    func arguments(after position: Int, declaration: Bool) -> ArgumentList? {
        let open = position + 1
        guard token(at: open)?.isPunctuation("(") == true,
              let frame = brackets.frame(at: open), let closing = frame.closing else { return nil }
        let starts = declaration ? frame.declarationArgumentStarts : frame.callArgumentStarts
        return ArgumentList(labels: starts.map { label(at: $0, declaration: declaration) }, closingIndex: closing)
    }

    private func label(at index: Int, declaration: Bool) -> String {
        let current = tokens[index]
        guard current.kind == .identifier else { return "_" }
        if declaration { return current.text }
        return token(at: index + 1)?.isPunctuation(":") == true ? current.text : "_"
    }

    /// The number of parameters of the closure that opens at `brace`: from its signature when
    /// it has one (`{ old, new in`, `{ (value) in`, `{ [weak self] value in`), otherwise from the
    /// highest shorthand argument (`$0`, `$1`) used directly in its body. `nil` when the closure
    /// never closes.
    ///
    /// The signature search stops at the first token that cannot be part of a signature, which
    /// includes any nested `{`, so each token is looked at by one closure at most.
    func closureParameterCount(openingBraceAt brace: Int) -> Int? {
        guard let frame = brackets.frame(at: brace), let closing = frame.closing else { return nil }
        var index = brace + 1
        if token(at: index)?.isPunctuation("[") == true {
            guard let captureListEnd = brackets.frame(at: index)?.closing else { return nil }
            index = captureListEnd + 1
        }
        let signatureStart = index
        while index < closing {
            let current = tokens[index]
            if current.isIdentifier("in") {
                return parameterCount(signature: tokens[signatureStart..<index])
            }
            let isSignatureToken = current.kind == .identifier
                ? !Self.statementKeywords.contains(current.text)
                : current.kind == .punctuation && Self.signatureMarks.contains(current.text)
            guard isSignatureToken else { break }
            index += 1
        }
        return frame.highestShorthandArgument + 1
    }

    private func parameterCount(signature: ArraySlice<Token>) -> Int {
        guard let first = signature.first else { return 0 }
        if first.isPunctuation("(") {
            var depth = 0
            var commas = 0
            var isEmpty = true
            for current in signature {
                if current.isPunctuation("(") { depth += 1; continue }
                if current.isPunctuation(")") {
                    depth -= 1
                    if depth == 0 { break }
                    continue
                }
                isEmpty = false
                if depth == 1, current.isPunctuation(",") { commas += 1 }
            }
            return isEmpty ? 0 : commas + 1
        }
        let names = signature.prefix { !$0.isPunctuation("-") && !$0.isIdentifier("throws") && !$0.isIdentifier("async") }
        return names.filter { $0.isPunctuation(",") }.count + 1
    }
}
