import Testing
@testable import MigrationScanner

@Suite("Lexer")
struct LexerTests {
    private func identifiers(_ source: String) -> [String] {
        Lexer.lex(source).tokens.filter { $0.kind == .identifier }.map(\.text)
    }

    @Test("Line and nested block comments are not code")
    func comments() {
        let source = """
        // UIScreen.main
        /* UIScreen.main /* nested UIScreen.main */ still a comment UIScreen.main */
        let a = 1
        """
        #expect(identifiers(source) == ["let", "a"])
        #expect(Lexer.lex(source).comments.count == 2)
    }

    @Test("String contents are not code", arguments: [
        #"let s = "UIScreen.main""#,
        #"let s = "escaped \" UIScreen.main""#,
        ##"let s = #"raw "UIScreen.main" \(not interpolation)"#"##,
        ###"let s = ##"two "# hashes UIScreen.main"##"###,
        "let s = \"\"\"\nUIScreen.main\n\"still inside\"\n\"\"\"",
        "let r = #/UIScreen\\.main/#"
    ])
    func strings(source: String) {
        #expect(!identifiers(source).contains("UIScreen"))
    }

    @Test("Code inside a string interpolation is code")
    func interpolation() {
        let ids = identifiers(#"let s = "scale: \(UIScreen.main.scale(f("x)"))) done""#)
        #expect(ids == ["let", "s", "UIScreen", "main", "scale", "f"])
    }

    @Test("Raw string interpolation needs the matching hashes")
    func rawInterpolation() {
        #expect(identifiers(##"let s = #"\#(UIScreen.main)"#"##).contains("UIScreen"))
        #expect(!identifiers(##"let s = #"\(UIScreen.main)"#"##).contains("UIScreen"))
    }

    @Test("Nested interpolations with strings inside")
    func nestedInterpolation() {
        let source = #"let s = "a \("b \(UIScreen.main) c") d"; let after = 1"#
        #expect(identifiers(source) == ["let", "s", "UIScreen", "main", "let", "after"])
    }

    @Test("An unterminated single-line string ends at the end of the line")
    func unterminatedString() {
        let source = "let s = \"never closed UIScreen.main\nlet next = UIScreen.main"
        #expect(identifiers(source) == ["let", "s", "let", "next", "UIScreen", "main"])
    }

    @Test("An unterminated comment or multi-line string runs to the end of the file")
    func unterminatedToEndOfFile() {
        #expect(identifiers("let a = 1 /* open UIScreen.main") == ["let", "a"])
        #expect(identifiers("let a = \"\"\"\nUIScreen.main") == ["let", "a"])
    }

    @Test("Locations are 1-based, count Unicode scalars and treat CRLF as one line break")
    func locations() {
        let tokens = Lexer.lex("let 🙂 = 1\r\n  UIScreen.main").tokens
        let screen = tokens.first { $0.text == "UIScreen" }
        #expect(screen?.location == SourceLocation(line: 2, column: 3))
        let one = tokens.first { $0.text == "1" }
        #expect(one?.location == SourceLocation(line: 1, column: 9))
    }

    @Test("Backtick identifiers and shorthand arguments")
    func identifierForms() {
        #expect(identifiers("let `default` = $0 + $12") == ["let", "default", "$0", "$12"])
    }

    @Test("A comment after code records that it follows code")
    func trailingComment() {
        let comments = Lexer.lex("let a = 1 // trailing\n// own line").comments
        #expect(comments.map(\.followsCode) == [true, false])
        #expect(comments.map(\.line) == [1, 2])
    }

    @Test("Deep nesting of comments and interpolations is linear and does not recurse")
    func deepNesting() {
        let comment = String(repeating: "/*", count: 50_000) + String(repeating: "*/", count: 50_000) + " let a = 1"
        #expect(identifiers(comment) == ["let", "a"])
        let interpolation = "let s = " + String(repeating: "\"\\(", count: 20_000) + "x" + String(repeating: ")\"", count: 20_000)
        #expect(identifiers(interpolation) == ["let", "s", "x"])
    }
}
