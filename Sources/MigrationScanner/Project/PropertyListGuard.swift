import Foundation

/// Decides whether a file may be handed to `PropertyListSerialization`.
///
/// The system parser is recursive: an XML or binary property list nested a few thousand levels
/// deep, which fits in a few kilobytes, can exhaust the stack of the thread that parses it. An
/// Info.plist is a shallow dictionary, so anything nested deeper than ``maximumDepth``, a binary
/// property list whose object graph has a cycle or does not fit its own offset table, XML that
/// the guard could read differently from the parser (see ``XMLPropertyListScanner``), and the old
/// OpenStep text format are all refused before parsing. Every check is iterative and linear in
/// the size of the file: a binary property list is walked once per distinct object offset, and
/// one whose containers hold more references than the file has bytes is refused.
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

    /// Where `object` starts, or `nil` when the offset table points outside the objects.
    private func offset(of object: Int) -> Int? {
        let offset = Self.integer(bytes, at: offsetTableStart + object * offsetSize, size: offsetSize)
        guard offset >= 8, offset < UInt64(offsetTableStart) else { return nil }
        return Int(offset)
    }

    /// Where the objects that the array, set or dictionary at `offset` refers to start; `[]` for
    /// other objects; `nil` when the object or its references fall outside the file, or when it
    /// would take the references read so far past `budget`.
    private func children(at offset: Int, budget: inout Int) -> [Int]? {
        var position = offset
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
        guard references <= UInt64(budget) else { return nil }
        budget -= Int(references)
        var result: [Int] = []
        result.reserveCapacity(Int(references))
        for index in 0..<Int(references) {
            let reference = Self.integer(bytes, at: position + index * referenceSize, size: referenceSize)
            guard reference < UInt64(objectCount), let child = self.offset(of: Int(reference)) else { return nil }
            result.append(child)
        }
        return result
    }

    /// Walks the object graph without recursion. Returns `false` for a cycle, a malformed object,
    /// or a path longer than `limit` objects, also through objects shared by several containers
    /// (their height is remembered).
    ///
    /// Objects are told apart by their offset, so objects that share one are expanded once, as
    /// the system parser reads them once. Containers that a writer lays out one after the other
    /// hold fewer references in total than the file has bytes; more than that means containers
    /// overlap, which would make the work quadratic, and the file is refused.
    func isWithinDepth(_ limit: Int) -> Bool {
        var heights: [Int: Int] = [:]
        var inProgress: Set<Int> = []
        var budget = offsetTableStart
        guard let root = offset(of: topObject), let rootChildren = children(at: root, budget: &budget) else {
            return false
        }
        var stack: [(offset: Int, children: [Int], next: Int)] = [(root, rootChildren, 0)]
        inProgress.insert(root)
        while let frame = stack.last {
            guard frame.next < frame.children.count else {
                heights[frame.offset] = 1 + (frame.children.map { heights[$0] ?? 0 }.max() ?? 0)
                inProgress.remove(frame.offset)
                stack.removeLast()
                continue
            }
            stack[stack.count - 1].next += 1
            let child = frame.children[frame.next]
            if let height = heights[child] {
                if stack.count + height > limit { return false }
            } else {
                guard !inProgress.contains(child), stack.count < limit,
                      let grandchildren = children(at: child, budget: &budget) else { return false }
                inProgress.insert(child)
                stack.append((child, grandchildren, 0))
            }
        }
        return true
    }
}
