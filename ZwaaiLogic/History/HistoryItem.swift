import Foundation

public struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    public let id: UUID
    public let timestamp: Date
    public var type: ZwaaiType
    public let random: Random

    public init(id: UUID, timestamp: Date, type: ZwaaiType, random: Random) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.random = random
    }

    public var description: String {
        return "(\(id), \(DateFormatter.shortNL.string(from: timestamp)), \(type), \(random))"
    }
}

extension Array where Element == HistoryItem {
    public func sorted() -> [HistoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            item1.timestamp > item2.timestamp
        }
    }
}
