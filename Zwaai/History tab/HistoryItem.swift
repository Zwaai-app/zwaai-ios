import Foundation

struct HistoryItem: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let type: ZwaaiType
    let random: Random
}

enum ZwaaiType: String {
    case person
    case room
}
