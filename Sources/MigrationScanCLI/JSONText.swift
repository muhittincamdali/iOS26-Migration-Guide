import Foundation

enum JSONText {
    static func encode(_ value: some Encodable) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        // Plain strings and enums only: encoding cannot fail.
        let data = (try? encoder.encode(value)) ?? Data("[]".utf8)
        return String(decoding: data, as: UTF8.self) + "\n"
    }
}
