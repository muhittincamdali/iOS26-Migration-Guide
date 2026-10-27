/// The bracket structure of a file, computed in one pass so every later question about it costs
/// constant or argument-count time.
///
/// For each `(`, `[` and `{` it records where the bracket closes. For each `(` it records where
/// its arguments start: once counting every top-level comma (a call), and once ignoring commas
/// inside generic angle brackets (a declaration such as `options: Dictionary<Key, Any>`). For each
/// `{` it records the highest shorthand argument (`$0`, `$1`, …) used inside it but not inside a
/// nested closure.
/// Without this, a file of nested or unclosed calls would make each call rescan the rest of the
/// file.
struct BracketIndex {
    struct Frame {
        var closing: Int?
        var callArgumentStarts: [Int] = []
        var declarationArgumentStarts: [Int] = []
        var highestShorthandArgument = -1
    }

    private let frames: [Int: Frame]

    init(tokens: [Token]) {
        var frames: [Int: Frame] = [:]
        struct Open {
            let index: Int
            let mark: String
            /// The innermost `{` that contains this bracket, or the bracket itself.
            let enclosingBrace: Int?
            var angleDepth = 0
            var expectsCallArgument: Bool
            var expectsDeclarationArgument: Bool
        }
        var stack: [Open] = []
        for (index, token) in tokens.enumerated() {
            if let top = stack.last, top.mark == "(" {
                recordArgumentStart(index, in: &stack[stack.count - 1], closesList: token.isPunctuation(")"))
            }
            guard token.kind != .string else { continue }
            if token.kind == .identifier {
                recordShorthand(token, in: stack.last)
                continue
            }
            switch token.text {
            case "(", "[", "{":
                frames[index] = Frame()
                let isList = token.text == "("
                let brace = token.text == "{" ? index : stack.last?.enclosingBrace
                stack.append(Open(
                    index: index, mark: token.text, enclosingBrace: brace,
                    expectsCallArgument: isList, expectsDeclarationArgument: isList
                ))
            case ")", "]", "}":
                if let open = stack.popLast() { frames[open.index]?.closing = index }
            case ",":
                guard let top = stack.last, top.mark == "(" else { continue }
                stack[stack.count - 1].expectsCallArgument = true
                if top.angleDepth == 0 { stack[stack.count - 1].expectsDeclarationArgument = true }
            case "<":
                if stack.last?.mark == "(" { stack[stack.count - 1].angleDepth += 1 }
            case ">":
                if let top = stack.last, top.mark == "(", top.angleDepth > 0 { stack[stack.count - 1].angleDepth -= 1 }
            default:
                continue
            }
        }
        self.frames = frames

        func recordArgumentStart(_ index: Int, in open: inout Open, closesList: Bool) {
            guard !closesList else { return }
            if open.expectsCallArgument {
                frames[open.index]?.callArgumentStarts.append(index)
                open.expectsCallArgument = false
            }
            if open.expectsDeclarationArgument {
                frames[open.index]?.declarationArgumentStarts.append(index)
                open.expectsDeclarationArgument = false
            }
        }

        func recordShorthand(_ token: Token, in open: Open?) {
            guard let brace = open?.enclosingBrace, token.text.first == "$",
                  let number = Int(token.text.dropFirst()), number < 64 else { return }
            let highest = frames[brace]?.highestShorthandArgument ?? -1
            frames[brace]?.highestShorthandArgument = max(highest, number)
        }
    }

    func frame(at opener: Int) -> Frame? {
        frames[opener]
    }
}
