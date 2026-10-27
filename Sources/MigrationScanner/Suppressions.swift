/// The `migration-scan:` comments of one file.
///
/// ```swift
/// let scale = UIScreen.main.scale // migration-scan:ignore uiscreen-main -- the widget has no window
///
/// // migration-scan:ignore uiapplication-windows, uiapplication-key-window
/// let window = UIApplication.shared.windows.first
///
/// // migration-scan:ignore-file all
/// ```
///
/// `ignore` after code applies to its own line; on a line of its own it applies to the next
/// line. `ignore-file` applies to the whole file. Rules are separated by spaces or commas, `all`
/// names every rule, and anything after `--` is a free-form reason. A directive with an unknown
/// command, no rule, or a rule that does not exist is reported as a ``Notice`` and ignored.
struct Suppressions {
    static let prefix = "migration-scan:"
    private static let everyRule = "all"

    private var fileWide: Set<String> = []
    private var byLine: [Int: Set<String>] = [:]
    private(set) var invalidDirectiveLines: [Int] = []

    init(comments: [Comment]) {
        for comment in comments {
            parse(comment)
        }
    }

    func suppresses(_ ruleID: String, line: Int?) -> Bool {
        if fileWide.contains(Self.everyRule) || fileWide.contains(ruleID) { return true }
        guard let line, let ids = byLine[line] else { return false }
        return ids.contains(Self.everyRule) || ids.contains(ruleID)
    }

    private mutating func parse(_ comment: Comment) {
        // `///` and `/**` comments arrive with their extra `/` or `*`.
        let text = comment.text.drop { $0 == "/" || $0 == "*" || $0 == "!" || $0.isWhitespace }
        guard text.hasPrefix(Self.prefix) else { return }
        let body = text.dropFirst(Self.prefix.count)
        let words = body.split(whereSeparator: { $0.isWhitespace || $0 == "," })
        guard let command = words.first else {
            invalidDirectiveLines.append(comment.line)
            return
        }
        let ids = Set(words.dropFirst().prefix { $0 != "--" }.map(String.init))
        let known = ids.allSatisfy { $0 == Self.everyRule || RuleCatalog.rule(id: $0) != nil }
        guard !ids.isEmpty, known else {
            invalidDirectiveLines.append(comment.line)
            return
        }
        switch command {
        case "ignore-file":
            fileWide.formUnion(ids)
        case "ignore":
            let line = comment.followsCode ? comment.line : comment.line + 1
            byLine[line, default: []].formUnion(ids)
        default:
            invalidDirectiveLines.append(comment.line)
        }
    }
}
