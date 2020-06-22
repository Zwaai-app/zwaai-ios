import Foundation

private let timestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "nl_NL")
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    let id: UUID
    let timestamp: Date
    let type: ZwaaiType
    let random: Random

    var description: String {
        return "(\(id), \(timestampFormatter.string(from: timestamp)), \(type), \(random))"
    }
}

enum ZwaaiType: String, Codable {
    case person
    case room
}
