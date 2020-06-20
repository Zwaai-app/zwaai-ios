import Foundation

struct Random: Equatable {
    let bytes: Data

    init() {
        let random:[UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
        self.bytes = Data(random)
    }

    init?(bytes: Data) {
        guard bytes.count == 16 else { return nil }
        self.bytes = bytes
    }

    init?(base64Encoded string: String) {
        guard let data = Data(base64Encoded: string) else { return nil }
        self.init(bytes: data)
    }

    func base64EncodedString() -> String {
        return self.bytes.base64EncodedString()
    }

    func hexEncodedString() -> String {
        return bytes.map { String(format: "%.2x", $0) }.reduce("", {$0+$1})
    }
}
