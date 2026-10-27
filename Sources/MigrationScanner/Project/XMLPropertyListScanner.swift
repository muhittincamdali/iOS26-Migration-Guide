/// Measures the nesting of an XML property list in one forward pass, reading markup the way the
/// system parser reads it, and refuses the file wherever the two could read the same bytes
/// differently. A guard that skips a region the parser reads as markup undercounts the depth, so
/// every rule below keeps the guard's view a superset of the parser's:
///
/// - A tag ends at its first `>` and contains no `<`. An attribute value such as `x="<!--"` cannot
///   open a comment the parser never sees.
/// - A DOCTYPE comes once, before the root element. The parser ends it at the first `>` or `[`
///   without regard to quotes, so a `>` inside a quoted literal, a `<` anywhere and an internal
///   subset (`[`, the only place entities are declared) are refused.
/// - A processing instruction has no `<` or `>` before its `?>`. One that names an encoding names
///   UTF-8, US-ASCII or ISO-8859-1, where every byte below 0x80 is that ASCII character. In UTF-7,
///   for example, `+ADw-` is a `<`.
/// - Comments and CDATA sections end at their first `-->` and `]]>`; markup inside them is text.
/// - Any other `<!` is refused, and so is a closing `array` or `dict` tag with no opening one.
///
/// Every check is linear in the size of the file.
struct XMLPropertyListScanner {
    private let bytes: [UInt8]
    private var index = 0
    private var depth = 0
    private var hasElement = false
    private var hasDoctype = false

    private init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    /// Whether the document is markup this scanner can read and nests at most `limit` arrays and
    /// dictionaries on any path.
    static func isWithinDepth(_ bytes: [UInt8], limit: Int) -> Bool {
        var scanner = Self(bytes: bytes)
        return scanner.scan(limit: limit)
    }

    private mutating func scan(limit: Int) -> Bool {
        if bytes.starts(with: Self.utf8ByteOrderMark) { index = Self.utf8ByteOrderMark.count }
        while index < bytes.count, Self.whitespace.contains(bytes[index]) { index += 1 }
        guard index < bytes.count, bytes[index] == Self.lessThan else { return false }
        while index < bytes.count {
            guard bytes[index] == Self.lessThan else {
                index += 1
                continue
            }
            guard readMarkup(limit: limit) else { return false }
        }
        return true
    }

    /// Reads the markup that starts at the `<` at `index` and moves past it.
    private mutating func readMarkup(limit: Int) -> Bool {
        if hasPrefix(Self.commentStart) { return skip(opening: Self.commentStart, closing: Self.commentEnd) }
        if hasPrefix(Self.cdataStart) { return skip(opening: Self.cdataStart, closing: Self.cdataEnd) }
        if hasPrefix(Self.instructionStart) { return readProcessingInstruction() }
        if hasPrefix(Self.doctypeStart) { return readDoctype() }
        if hasPrefix(Self.declarationStart) { return false }
        return readTag(limit: limit)
    }

    private mutating func skip(opening: [UInt8], closing: [UInt8]) -> Bool {
        guard let end = firstIndex(of: closing, from: index + opening.count) else { return false }
        index = end + closing.count
        return true
    }

    private mutating func readProcessingInstruction() -> Bool {
        let bodyStart = index + Self.instructionStart.count
        guard let end = firstIndex(of: Self.instructionEnd, from: bodyStart) else { return false }
        let body = bytes[bodyStart..<end]
        guard !body.contains(Self.lessThan), !body.contains(Self.greaterThan),
              Self.namesASCIICompatibleEncodings(body) else { return false }
        index = end + Self.instructionEnd.count
        return true
    }

    private mutating func readDoctype() -> Bool {
        guard !hasElement, !hasDoctype else { return false }
        hasDoctype = true
        var quote: UInt8?
        for position in (index + Self.doctypeStart.count)..<bytes.count {
            switch bytes[position] {
            case Self.lessThan, Self.openingBracket:
                return false
            case Self.greaterThan:
                guard quote == nil else { return false }
                index = position + 1
                return true
            case let mark where Self.quotes.contains(mark):
                if quote == nil { quote = mark } else if quote == mark { quote = nil }
            default:
                continue
            }
        }
        return false
    }

    /// A start, end or empty-element tag; only `array` and `dict` change the depth.
    private mutating func readTag(limit: Int) -> Bool {
        let isClosing = index + 1 < bytes.count && bytes[index + 1] == Self.slash
        let nameStart = index + (isClosing ? 2 : 1)
        var end = nameStart
        while end < bytes.count, bytes[end] != Self.greaterThan {
            if bytes[end] == Self.lessThan { return false }
            end += 1
        }
        guard end < bytes.count else { return false }
        hasElement = true
        index = end + 1
        guard startsContainer(at: nameStart) else { return true }
        if isClosing {
            depth -= 1
            return depth >= 0
        }
        if bytes[end - 1] == Self.slash { return true }
        depth += 1
        return depth <= limit
    }

    /// `array` or `dict` followed by `>`, `/` or whitespace.
    private func startsContainer(at start: Int) -> Bool {
        Self.containerNames.contains { name in
            let end = start + name.count
            guard end < bytes.count, bytes[start..<end].elementsEqual(name) else { return false }
            return bytes[end] == Self.greaterThan || bytes[end] == Self.slash || Self.whitespace.contains(bytes[end])
        }
    }

    private func hasPrefix(_ prefix: [UInt8]) -> Bool {
        index + prefix.count <= bytes.count && bytes[index..<(index + prefix.count)].elementsEqual(prefix)
    }

    /// The first position at or after `start` where `needle` begins. The needles are a few bytes
    /// long, so the scan stays linear in the size of the file.
    private func firstIndex(of needle: [UInt8], from start: Int) -> Int? {
        guard start <= bytes.count - needle.count else { return nil }
        for position in start...(bytes.count - needle.count) where bytes[position] == needle[0] {
            if bytes[position..<(position + needle.count)].elementsEqual(needle) { return position }
        }
        return nil
    }

    /// Whether every `encoding` the instruction mentions is followed by `=` and a quoted name of
    /// an encoding in which bytes below 0x80 are ASCII.
    private static func namesASCIICompatibleEncodings(_ body: ArraySlice<UInt8>) -> Bool {
        var rest = String(decoding: body, as: UTF8.self).lowercased()[...]
        while let mention = rest.range(of: "encoding") {
            rest = rest[mention.upperBound...].drop { $0.isWhitespace }
            guard rest.first == "=" else { return false }
            rest = rest.dropFirst().drop { $0.isWhitespace }
            guard let quote = rest.first, quote == "\"" || quote == "'" else { return false }
            rest = rest.dropFirst()
            guard let close = rest.firstIndex(of: quote), asciiCompatibleEncodings.contains(String(rest[..<close])) else {
                return false
            }
            rest = rest[rest.index(after: close)...]
        }
        return true
    }

    private static let asciiCompatibleEncodings: Set<String> = ["utf-8", "us-ascii", "iso-8859-1"]
    private static let containerNames = [Array("array".utf8), Array("dict".utf8)]
    private static let utf8ByteOrderMark: [UInt8] = [0xEF, 0xBB, 0xBF]
    private static let whitespace: [UInt8] = [0x20, 0x09, 0x0A, 0x0D]
    private static let quotes: [UInt8] = [UInt8(ascii: "\""), UInt8(ascii: "'")]
    private static let lessThan = UInt8(ascii: "<")
    private static let greaterThan = UInt8(ascii: ">")
    private static let slash = UInt8(ascii: "/")
    private static let openingBracket = UInt8(ascii: "[")
    private static let commentStart = Array("<!--".utf8)
    private static let commentEnd = Array("-->".utf8)
    private static let cdataStart = Array("<![CDATA[".utf8)
    private static let cdataEnd = Array("]]>".utf8)
    private static let instructionStart = Array("<?".utf8)
    private static let instructionEnd = Array("?>".utf8)
    private static let doctypeStart = Array("<!DOCTYPE".utf8)
    private static let declarationStart = Array("<!".utf8)
}
