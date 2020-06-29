import Foundation

public struct Random: Equatable, Codable, CustomStringConvertible {
    let bytes: Data

    public init() {
        let random: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
        self.bytes = Data(random)
    }

    public init?(bytes: Data) {
        guard bytes.count == 16 else { return nil }
        self.bytes = bytes
    }

    public init?(hexEncoded string: String) {
        guard string.count == 32, let data = Data(hexEncoded: string) else { return nil }
        self.init(bytes: data)
    }

    public func hexEncodedString() -> String {
        return bytes.hexEncodedString()
    }

    public var description: String {
        return hexEncodedString()
    }
}
