/// Makes file paths safe to print.
///
/// A path is the one piece of a report that comes from outside the rule catalog, and file names
/// may contain any character but `/` and NUL. Written as is, a newline in a name would start a
/// forged diagnostic line in Xcode or a forged `::error` command on GitHub, an escape sequence
/// would drive the terminal, and a bidirectional override would make the name read differently
/// from what it is. Each of those characters is written as `\u{…}` instead.
public enum OutputSanitizer {
    public static func sanitize(_ text: String) -> String {
        var result = ""
        result.unicodeScalars.reserveCapacity(text.unicodeScalars.count)
        for scalar in text.unicodeScalars {
            if isUnsafe(scalar) {
                result += "\\u{" + String(scalar.value, radix: 16, uppercase: true) + "}"
            } else {
                result.unicodeScalars.append(scalar)
            }
        }
        return result
    }

    static func isUnsafe(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x00...0x1F, 0x7F...0x9F: true          // C0 and C1 controls, DEL (newline, ESC, tab)
        case 0x2028, 0x2029: true                    // line and paragraph separators
        case 0x200E, 0x200F, 0x061C: true            // directional marks
        case 0x202A...0x202E, 0x2066...0x2069: true  // bidirectional embeddings, overrides, isolates
        case 0xFEFF: true                            // byte order mark
        default: false
        }
    }
}
