import Foundation

extension Data {
    /// Creates a new `Data` instance using the hexadecimal-encoded string.
    ///
    /// - Parameter string: A string with even non-zero length containing only digits or a/A through f/F.
    public init?(hexEncoded string: String) {
        if string.count == 0 || string.count % 2 != 0 { return nil }

        var bytes = [UInt8]()
        var start = string.startIndex
        while start < string.endIndex {
            let chunkEnd = string.index(start, offsetBy: 2)
            let chunk = string[start..<chunkEnd]
            guard let byte = UInt8(chunk, radix: 16) else { return nil }
            bytes.append(byte)
            start = chunkEnd
        }
        self.init(bytes)
    }

    /// Creates a hexadecimal string representation of the data.
    ///
    /// - Returns:A string with even non-zero length containing only digits or a/A through f/F.
    public func hexEncodedString() -> String {
        return [UInt8](self).map { String(format: "%.2x", $0) }.reduce("", {$0+$1})
    }
}
