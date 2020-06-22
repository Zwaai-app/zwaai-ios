import Foundation

struct Random: Equatable, Codable, CustomStringConvertible {
    let bytes: Data

    init() {
        let random: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
        self.bytes = Data(random)
    }

    init?(bytes: Data) {
        guard bytes.count == 16 else { return nil }
        self.bytes = bytes
    }

    init?(hexEncoded string: String) {
        guard string.count == 32 else { return nil }

        var bytes = [UInt8]()
        var start = string.startIndex
        while start < string.endIndex {
            let chunkEnd = string.index(start, offsetBy: 2)
            let chunk = string[start..<chunkEnd]
            guard let byte = UInt8(chunk, radix: 16) else { return nil }
            bytes.append(byte)
            start = chunkEnd
        }

        self.init(bytes: Data(bytes))
    }

    func hexEncodedString() -> String {
        return bytes.map { String(format: "%.2x", $0) }.reduce("", {$0+$1})
    }

    var description: String {
        return hexEncodedString()
    }
}
