import Foundation

struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    let id: UUID
    let timestamp: Date
    let type: ZwaaiType
    let random: Random

    var description: String {
        return "(\(id), \(DateFormatter.shortNL.string(from: timestamp)), \(type), \(random))"
    }
}

enum ZwaaiType: String, Codable {
    case person
    case room
}
