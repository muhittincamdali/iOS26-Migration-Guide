import Foundation
import Testing
@testable import MigrationScanner

/// Builds a `bplist00` file by hand: each object is an array of references, or `nil` for a
/// `true` value. References are 2 bytes, offsets 4 bytes.
private func binaryPropertyList(_ objects: [[Int]?], top: Int = 0, trailerOverride: ((inout [UInt8]) -> Void)? = nil) -> Data {
    var bytes = Array("bplist00".utf8)
    var offsets: [Int] = []
    for object in objects {
        offsets.append(bytes.count)
        guard let references = object else {
            bytes.append(0x09)
            continue
        }
        if references.count < 15 {
            bytes.append(0xA0 | UInt8(references.count))
        } else {
            bytes += [0xAF, 0x11, UInt8(references.count >> 8), UInt8(references.count & 0xFF)]
        }
        for reference in references { bytes += [UInt8(reference >> 8), UInt8(reference & 0xFF)] }
    }
    let tableOffset = bytes.count
    for offset in offsets { bytes += withUnsafeBytes(of: UInt32(offset).bigEndian, Array.init) }
    var trailer: [UInt8] = [0, 0, 0, 0, 0, 0, 4, 2]
    trailer += withUnsafeBytes(of: UInt64(objects.count).bigEndian, Array.init)
    trailer += withUnsafeBytes(of: UInt64(top).bigEndian, Array.init)
    trailer += withUnsafeBytes(of: UInt64(tableOffset).bigEndian, Array.init)
    trailerOverride?(&trailer)
    return Data(bytes + trailer)
}

/// `count` arrays, each holding the next, around a final `true`.
private func chain(_ count: Int) -> [[Int]?] {
    (0..<count).map { [$0 + 1] } + [nil]
}

/// `count` nested XML arrays.
private func nestedArrays(_ count: Int) -> String {
    String(repeating: "<array>", count: count) + String(repeating: "</array>", count: count)
}

/// How deep the system parser nests the value it reads from `data`. Callers keep the nesting far
/// below the depth that exhausts the stack, so this shows what the guard would let through.
private func parsedDepth(_ data: Data) throws -> Int {
    func depth(_ value: Any) -> Int {
        if let array = value as? [Any] { return 1 + (array.map(depth).max() ?? 0) }
        if let dictionary = value as? [String: Any] { return 1 + (dictionary.values.map(depth).max() ?? 0) }
        return 0
    }
    return depth(try PropertyListSerialization.propertyList(from: data, format: nil))
}

@Suite("Property list guard")
struct PropertyListGuardTests {
    @Test("Property lists written by the system pass")
    func systemPropertyLists() throws {
        let value: [String: Any] = ["UIApplicationSceneManifest": ["UISceneConfigurations": ["Role": [["Name": "Default"]]]]]
        for format in [PropertyListSerialization.PropertyListFormat.xml, .binary] {
            let data = try PropertyListSerialization.data(fromPropertyList: value, format: format, options: 0)
            #expect(PropertyListGuard.isSafeToParse(data))
        }
    }

    @Test("The hand-built binary format matches the system parser")
    func builderIsValid() throws {
        let data = binaryPropertyList(chain(3))
        #expect(PropertyListGuard.isSafeToParse(data))
        let parsed = try PropertyListSerialization.propertyList(from: data, format: nil)
        #expect(((parsed as? [Any])?.first as? [Any])?.count == 1)
    }

    @Test("Binary nesting deeper than the limit is refused before parsing")
    func deepBinary() {
        #expect(PropertyListGuard.isSafeToParse(binaryPropertyList(chain(PropertyListGuard.maximumDepth - 2))))
        #expect(!PropertyListGuard.isSafeToParse(binaryPropertyList(chain(20_000))))
    }

    @Test("Depth through a shared object counts the deepest path, whichever is visited first")
    func sharedObjectDepth() {
        // 0 = [shared, deep]; shared = a chain of 10; deep = a chain of 60 ending in shared.
        var objects: [[Int]?] = [[1, 12]]
        objects += (1...10).map { [$0 + 1] }  // 1 … 10 → 11
        objects.append(nil)                    // 11
        objects += (12..<71).map { [$0 + 1] }  // 12 … 70 → 71
        objects.append([1])                    // 71 → shared
        #expect(!PropertyListGuard.isSafeToParse(binaryPropertyList(objects)))
    }

    @Test("A reference cycle is refused")
    func cycle() {
        #expect(!PropertyListGuard.isSafeToParse(binaryPropertyList([[1], [0]])))
    }

    @Test("Trailers that point outside the file are refused without trapping", arguments: [
        (8, UInt64.max),   // object count
        (16, UInt64.max),  // top object
        (24, UInt64.max),  // offset table
        (8, 0)             // no objects
    ])
    func hostileTrailer(field: Int, value: UInt64) {
        let data = binaryPropertyList(chain(2)) { trailer in
            let bytes = withUnsafeBytes(of: value.bigEndian, Array.init)
            trailer.replaceSubrange(field..<(field + 8), with: bytes)
        }
        #expect(!PropertyListGuard.isSafeToParse(data))
    }

    @Test("A container count beyond the file is refused")
    func hostileCount() {
        var data = [UInt8](binaryPropertyList([[1], nil]))
        data[8] = 0xAF
        data[9] = 0x13  // an 8-byte count follows…
        #expect(!PropertyListGuard.isSafeToParse(Data(data)))
    }

    @Test("A dictionary count near UInt64.max is refused without overflowing")
    func hugeDictionaryCount() {
        // Object 0 at offset 8: a dictionary whose count is the 8-byte integer 0xFFFF_FFFF_FFFF_FFFF.
        // Object 1 at offset 18: true. The offset table follows at 19. Doubling the count for the
        // keys and values would overflow UInt64.
        var bytes = Array("bplist00".utf8)
        bytes += [0xDF, 0x13] + [UInt8](repeating: 0xFF, count: 8)
        bytes += [0x09]
        bytes += [0, 0, 0, 8, 0, 0, 0, 18]
        bytes += [0, 0, 0, 0, 0, 0, 4, 2]
        bytes += withUnsafeBytes(of: UInt64(2).bigEndian, Array.init)
        bytes += withUnsafeBytes(of: UInt64(0).bigEndian, Array.init)
        bytes += withUnsafeBytes(of: UInt64(19).bigEndian, Array.init)
        #expect(!PropertyListGuard.isSafeToParse(Data(bytes)))
    }

    @Test("Deep XML nesting, entity declarations and other text formats are refused")
    func xml() {
        let deep = "<?xml version=\"1.0\"?><plist><array>" + String(repeating: "<array>", count: 10_000)
            + String(repeating: "</array>", count: 10_001) + "</plist>"
        #expect(!PropertyListGuard.isSafeToParse(Data(deep.utf8)))
        let shallow = "<plist>" + String(repeating: "<array/>", count: 10_000) + "<dict><key>a</key><array></array></dict></plist>"
        #expect(PropertyListGuard.isSafeToParse(Data(shallow.utf8)))
        let entities = "<?xml version=\"1.0\"?><!DOCTYPE plist [<!ENTITY a \"aaaa\">]><plist><string>&a;</string></plist>"
        #expect(!PropertyListGuard.isSafeToParse(Data(entities.utf8)))
        #expect(!PropertyListGuard.isSafeToParse(Data("{ UIDesignRequiresCompatibility = YES; }".utf8)))
    }

    /// Closing tags hidden in a section that is not markup must not pay for nesting deeper than
    /// the limit afterwards.
    @Test("Closing tags inside comments, CDATA and processing instructions do not lower the depth", arguments: [
        ("<!--", "-->"),
        ("<plist><string><![CDATA[", "]]></string></plist>"),
        ("<?pi ", "?>")
    ])
    func hiddenClosingTags(opening: String, closing: String) {
        let extra = 1_000
        let hidden = opening + String(repeating: "</array>", count: extra) + closing
        let nested = String(repeating: "<array>", count: PropertyListGuard.maximumDepth + extra)
            + String(repeating: "</array>", count: PropertyListGuard.maximumDepth + extra)
        let document = "<?xml version=\"1.0\"?>" + hidden + "<plist>" + nested + "</plist>"
        #expect(!PropertyListGuard.isSafeToParse(Data(document.utf8)))
    }

    @Test("Markup inside comments and CDATA is ignored, and an unmatched closing tag is refused")
    func sectionsAndUnmatchedClosing() {
        let opened = String(repeating: "<array>", count: PropertyListGuard.maximumDepth * 2)
        let commented = "<plist><!--" + opened + "--><![CDATA[" + opened + "]]><array/></plist>"
        #expect(PropertyListGuard.isSafeToParse(Data(commented.utf8)))
        #expect(!PropertyListGuard.isSafeToParse(Data("<plist></array><array></array></plist>".utf8)))
        #expect(!PropertyListGuard.isSafeToParse(Data("<plist><!-- never closed <array></plist>".utf8)))
    }

    /// A `<` inside a tag or a DOCTYPE literal used to open a comment, CDATA section or processing
    /// instruction for the guard but not for the system parser, which ends both at the next `>`.
    /// The guard then skipped to the closing sequence at the end of the file and never counted the
    /// nesting in between, which the parser reads.
    @Test("Markup openers inside a DOCTYPE or a tag do not hide nesting from the guard", arguments: [
        ("<!DOCTYPE plist SYSTEM \"<!--\">", "", "<!-- end -->"),
        ("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN <!--\" \"x\">", "", "<!-- end -->"),
        ("", " x=\"<!--\"", "<!-- end -->"),
        ("<!DOCTYPE plist SYSTEM \"<?\">", "", "<?end?>"),
        ("", " x=\"<![CDATA[\"", "<!-- ]]> -->")
    ])
    func markupInsideDeclarations(doctype: String, attribute: String, trailer: String) throws {
        let document = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + doctype + "\n<plist version=\"1.0\"" + attribute
            + "><dict><key>k</key>" + nestedArrays(PropertyListGuard.maximumDepth * 3) + "</dict></plist>\n" + trailer
        let data = Data(document.utf8)
        #expect(try parsedDepth(data) > PropertyListGuard.maximumDepth)
        #expect(!PropertyListGuard.isSafeToParse(data))
    }

    /// The system parser decodes the whole file in the encoding named by the XML declaration, so
    /// in UTF-7 `+ADw-` is a `<` that a byte-level count never sees.
    @Test("An encoding other than UTF-8, US-ASCII or ISO-8859-1 is refused")
    func encodings() throws {
        let count = PropertyListGuard.maximumDepth * 3
        let hidden = String(repeating: "+ADw-array+AD4-", count: count) + String(repeating: "+ADw-/array+AD4-", count: count)
        let utf7 = Data(("<?xml version=\"1.0\" encoding=\"UTF-7\"?><plist><array>" + hidden + "</array></plist>").utf8)
        #expect(try parsedDepth(utf7) > PropertyListGuard.maximumDepth)
        #expect(!PropertyListGuard.isSafeToParse(utf7))
        for name in ["utf-7", "ISO-2022-JP", "UTF-16", "IBM037", "x-unknown"] {
            let declared = "<?xml version=\"1.0\" encoding=\"\(name)\"?><plist><true/></plist>"
            #expect(!PropertyListGuard.isSafeToParse(Data(declared.utf8)), "\(name)")
        }
        for name in ["UTF-8", "utf-8", "US-ASCII", "ISO-8859-1"] {
            let declared = "<?xml version=\"1.0\" encoding=\"\(name)\"?><plist><true/></plist>"
            #expect(PropertyListGuard.isSafeToParse(Data(declared.utf8)), "\(name)")
        }
    }

    @Test("DOCTYPE subsets, misplaced declarations and markup inside processing instructions are refused", arguments: [
        "<!DOCTYPE plist [ <!ELEMENT plist ANY> ]><plist><true/></plist>",
        "<!DOCTYPE plist SYSTEM \"a>b\"><plist><true/></plist>",
        "<!DOCTYPE plist SYSTEM \"<![CDATA[\"><plist><true/></plist><!-- ]]> -->",
        "<!DOCTYPE plist SYSTEM \"x><plist><true/></plist>",
        "<plist><array><!DOCTYPE plist></array></plist>",
        "<!DOCTYPE plist><!DOCTYPE plist><plist><true/></plist>",
        "<!doctype plist><plist><true/></plist>",
        "<plist><array><!FOO x></array></plist>",
        "<?pi > <array> ?><plist><true/></plist>",
        "<plist version=\"1.0\"<true/></plist>",
        "<plist><array x=\"1\"</array></plist>"
    ])
    func refusedMarkup(document: String) {
        #expect(!PropertyListGuard.isSafeToParse(Data(document.utf8)))
    }

    @Test("Property lists with an Apple DOCTYPE, comments, CDATA and processing instructions still pass")
    func validMarkup() throws {
        let document = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <!-- Written by hand: <array> in a comment is text. -->
            <plist version="1.0">
            <dict>
            \t<!-- The scene manifest. -->
            \t<key>UIApplicationSceneManifest</key>
            \t<dict>
            \t\t<key>UISceneConfigurations</key>
            \t\t<dict/>
            \t</dict>
            \t<key>Note</key>
            \t<string><![CDATA[<array> & <dict> are text here]]></string>
            \t<?editor fold?>
            \t<key>UIDesignRequiresCompatibility</key>
            \t<true/>
            </dict>
            </plist>
            """
        let data = Data(document.utf8)
        #expect(PropertyListGuard.isSafeToParse(data))
        #expect(try parsedDepth(data) == 3)
    }

    @Test("A deep Info.plist in a project becomes a notice, not a crash")
    func deepInfoPlistInProject() throws {
        let project = try TemporaryDirectory()
        try project.write("App/Info.plist", binaryPropertyList(chain(50_000)))
        #expect(project.scan().notices.map(\.kind) == [.invalidPropertyList])
    }

    @Test("An Info.plist that hides its nesting from the guard becomes a notice")
    func hiddenNestingInProject() throws {
        let project = try TemporaryDirectory()
        let document = "<!DOCTYPE plist SYSTEM \"<!--\">\n<plist><dict><key>k</key>" + nestedArrays(20_000)
            + "</dict></plist>\n<!-- end -->"
        try project.write("App/Info.plist", Data(document.utf8))
        let notices = project.scan().notices
        #expect(notices.map(\.kind) == [.invalidPropertyList])
        #expect(notices.first?.message.contains("refuses to parse") == true)
    }
}
