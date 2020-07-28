import Foundation

public struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    public let id: UUID
    public let timestamp: Date
    public var type: ZwaaiType

    public init(id: UUID, timestamp: Date, type: ZwaaiType) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
    }

    public var description: String {
        return "(\(id), \(DateFormatter.shortNL.string(from: timestamp)), \(type))"
    }
}

extension Array where Element == HistoryItem {
    public func sorted() -> [HistoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            item1.timestamp > item2.timestamp
        }
    }
}
