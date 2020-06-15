import Foundation

struct HistoryItem: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let type: ZwaaiType
}

enum ZwaaiType {
    case Person
    case Room
}
