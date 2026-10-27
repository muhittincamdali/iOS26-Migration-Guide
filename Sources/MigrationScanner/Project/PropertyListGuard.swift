import Foundation

/// Decides whether a file may be handed to `PropertyListSerialization`.
///
/// The system parser is recursive: an XML or binary property list nested a few thousand levels
/// deep, which fits in a few kilobytes, can exhaust the stack of the thread that parses it. An
/// Info.plist is a shallow dictionary, so anything nested deeper than ``maximumDepth``, a binary
/// property list whose object graph has a cycle or does not fit its own offset table, an XML
/// document that declares entities, and the old OpenStep text format are all refused before
/// parsing. Every check is iterative and linear in the size of the file.
enum PropertyListGuard {
    static let maximumDepth = 64
    private static let binaryMagic = Array("bplist00".utf8)

    static func isSafeToParse(_ data: Data) -> Bool {
        let bytes = [UInt8](data)
        if bytes.starts(with: binaryMagic) {
            return BinaryPropertyList(bytes: bytes)?.isWithinDepth(maximumDepth) ?? false
        }
        return isSafeXML(bytes)
    }

    // MARK: - XML

    private static func isSafeXML(_ bytes: [UInt8]) -> Bool {
        var start = 0
        if bytes.starts(with: [0xEF, 0xBB, 0xBF]) { start = 3 }
        while start < bytes.count, [0x20, 0x09, 0x0A, 0x0D].contains(bytes[start]) { start += 1 }
        guard start < bytes.count, bytes[start] == UInt8(ascii: "<") else { return false }
        if contains(Array("<!ENTITY".utf8), in: bytes) { return false }
        var depth = 0
        var index = start
        while index < bytes.count {
            defer { index += 1 }
            guard bytes[index] == UInt8(ascii: "<") else { continue }
            let isClosing = index + 1 < bytes.count && bytes[index + 1] == UInt8(ascii: "/")
            let nameStart = index + (isClosing ? 2 : 1)
            guard startsContainer(bytes, at: nameStart) else { continue }
            if isClosing {
                depth -= 1
                continue
            }
            if !isSelfClosing(bytes, from: nameStart) {
                depth += 1
                if depth > maximumDepth { return false }
            }
        }
        return true
    }

    /// `array` or `dict` followed by `>`, `/` or whitespace.
    private static func startsContainer(_ bytes: [UInt8], at index: Int) -> Bool {
        for name in [Array("array".utf8), Array("dict".utf8)] {
            let end = index + name.count
            guard end < bytes.count, Array(bytes[index..<end]) == name else { continue }
            if [UInt8(ascii: ">"), UInt8(ascii: "/"), 0x20, 0x09, 0x0A, 0x0D].contains(bytes[end]) { return true }
        }
        return false
    }

    private static func isSelfClosing(_ bytes: [UInt8], from index: Int) -> Bool {
        var position = index
        while position < bytes.count, bytes[position] != UInt8(ascii: ">") { position += 1 }
        return position < bytes.count && position > 0 && bytes[position - 1] == UInt8(ascii: "/")
    }

    private static func contains(_ needle: [UInt8], in bytes: [UInt8]) -> Bool {
        guard !needle.isEmpty, bytes.count >= needle.count else { return false }
        for start in 0...(bytes.count - needle.count) where bytes[start] == needle[0] {
            if Array(bytes[start..<(start + needle.count)]) == needle { return true }
        }
        return false
    }
}

/// The parts of the `bplist00` format needed to measure the depth of its object graph.
private struct BinaryPropertyList {
    private let bytes: [UInt8]
    private let objectCount: Int
    private let topObject: Int
    private let offsetTableStart: Int
    private let offsetSize: Int
    private let referenceSize: Int

    /// Reads and bounds-checks the 32-byte trailer. Every 64-bit field is compared with the file
    /// size before it becomes an `Int`, so no conversion can trap.
    init?(bytes: [UInt8]) {
        guard bytes.count >= 8 + 32 else { return nil }
        let trailer = bytes.count - 32
        let offsetSize = Int(bytes[trailer + 6])
        let referenceSize = Int(bytes[trailer + 7])
        guard (1...8).contains(offsetSize), (1...8).contains(referenceSize) else { return nil }
        let size = UInt64(bytes.count)
        let objects = Self.integer(bytes, at: trailer + 8, size: 8)
        let top = Self.integer(bytes, at: trailer + 16, size: 8)
        let table = Self.integer(bytes, at: trailer + 24, size: 8)
        guard objects > 0, objects <= size, top < objects, table >= 8, table < UInt64(trailer) else { return nil }
        // objects <= size and offsetSize <= 8, so the product fits comfortably in an Int.
        guard Int(table) + Int(objects) * offsetSize <= trailer else { return nil }
        self.bytes = bytes
        self.objectCount = Int(objects)
        self.topObject = Int(top)
        self.offsetTableStart = Int(table)
        self.offsetSize = offsetSize
        self.referenceSize = referenceSize
    }

    private static func integer(_ bytes: [UInt8], at start: Int, size: Int) -> UInt64 {
        bytes[start..<(start + size)].reduce(0) { ($0 << 8) | UInt64($1) }
    }

    /// The objects an array, set or dictionary refers to; `[]` for other objects; `nil` when the
    /// object or its references fall outside the file.
    private func children(of object: Int) -> [Int]? {
        let offset = Self.integer(bytes, at: offsetTableStart + object * offsetSize, size: offsetSize)
        guard offset >= 8, offset < UInt64(offsetTableStart) else { return nil }
        var position = Int(offset)
        let marker = bytes[position]
        let kind = marker >> 4
        guard kind == 0xA || kind == 0xC || kind == 0xD else { return [] }
        position += 1
        var count = UInt64(marker & 0x0F)
        if count == 0x0F {
            // The count follows as an integer object: marker 0x1n, then 2^n bytes.
            guard position < offsetTableStart, bytes[position] >> 4 == 0x1 else { return nil }
            let width = 1 << Int(bytes[position] & 0x0F)
            guard width <= 8, position + 1 + width <= offsetTableStart else { return nil }
            count = Self.integer(bytes, at: position + 1, size: width)
            position += 1 + width
        }
        // Compare before multiplying: a dictionary count near UInt64.max would overflow `count * 2`.
        let available = UInt64(offsetTableStart - position) / UInt64(referenceSize)
        guard count <= available, kind != 0xD || count <= available / 2 else { return nil }
        let references = kind == 0xD ? count * 2 : count
        var result: [Int] = []
        result.reserveCapacity(Int(references))
        for index in 0..<Int(references) {
            let reference = Self.integer(bytes, at: position + index * referenceSize, size: referenceSize)
            guard reference < UInt64(objectCount) else { return nil }
            result.append(Int(reference))
        }
        return result
    }

    /// Walks the object graph without recursion. Returns `false` for a cycle, a malformed object,
    /// or a path longer than `limit` objects, also through objects shared by several containers
    /// (their height is remembered). Each object is expanded once.
    func isWithinDepth(_ limit: Int) -> Bool {
        enum State { case unvisited, inProgress, done }
        var states = [State](repeating: .unvisited, count: objectCount)
        var heights = [Int](repeating: 0, count: objectCount)
        guard let rootChildren = children(of: topObject) else { return false }
        var stack: [(object: Int, children: [Int], next: Int)] = [(topObject, rootChildren, 0)]
        states[topObject] = .inProgress
        while let frame = stack.last {
            guard frame.next < frame.children.count else {
                heights[frame.object] = 1 + (frame.children.map { heights[$0] }.max() ?? 0)
                states[frame.object] = .done
                stack.removeLast()
                continue
            }
            stack[stack.count - 1].next += 1
            let child = frame.children[frame.next]
            switch states[child] {
            case .inProgress:
                return false
            case .done:
                if stack.count + heights[child] > limit { return false }
            case .unvisited:
                guard stack.count < limit, let grandchildren = children(of: child) else { return false }
                states[child] = .inProgress
                stack.append((child, grandchildren, 0))
            }
        }
        return true
    }
}
