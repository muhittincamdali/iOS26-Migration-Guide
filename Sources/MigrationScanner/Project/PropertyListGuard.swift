import Foundation

/// Decides whether a file may be handed to `PropertyListSerialization`.
///
/// The system parser is recursive: an XML or binary property list nested a few thousand levels
/// deep, which fits in a few kilobytes, can exhaust the stack of the thread that parses it. An
/// Info.plist is a shallow dictionary, so anything nested deeper than ``maximumDepth``, a binary
/// property list whose object graph has a cycle or does not fit its own offset table, XML that
/// the guard could read differently from the parser (see ``XMLPropertyListScanner``), and the old
/// OpenStep text format are all refused before parsing. Every check is iterative and linear in
/// the size of the file.
enum PropertyListGuard {
    static let maximumDepth = 64
    private static let binaryMagic = Array("bplist00".utf8)

    static func isSafeToParse(_ data: Data) -> Bool {
        let bytes = [UInt8](data)
        if bytes.starts(with: binaryMagic) {
            return BinaryPropertyList(bytes: bytes)?.isWithinDepth(maximumDepth) ?? false
        }
        return XMLPropertyListScanner.isWithinDepth(bytes, limit: maximumDepth)
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
