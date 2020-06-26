import Foundation

struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    let id: UUID
    let timestamp: Date
    let type: HistoryZwaaiType
    let random: Random

    var description: String {
        return "(\(id), \(DateFormatter.shortNL.string(from: timestamp)), \(type), \(random))"
    }
}

enum HistoryZwaaiType: String, Codable {
    case person
    case space
}
