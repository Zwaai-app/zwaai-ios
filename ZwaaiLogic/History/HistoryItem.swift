import Foundation

public struct HistoryItem: Identifiable, Equatable, Codable, CustomStringConvertible {
    public let id: UUID
    public let timestamp: Date
    public var type: HistoryZwaaiType
    public let random: Random

    public init(id: UUID, timestamp: Date, type: HistoryZwaaiType, random: Random) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.random = random
    }

    public var description: String {
        return "(\(id), \(DateFormatter.shortNL.string(from: timestamp)), \(type), \(random))"
    }
}

// sourcery: Prism
public enum HistoryZwaaiType: Codable, Equatable {
    case person
    case space(space: CheckedInSpace)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        if type == "person" {
            self = .person
        } else if type == "space" {
            let space = try container.decode(CheckedInSpace.self, forKey: .space)
            self = .space(space: space)
        } else {
            let error = AppError.invalidHistoryZwaaiType(type: type)
            throw AppError.decodeStateFailure(error: error)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .person: try container.encode("person", forKey: .type)
        case .space(let space):
            try container.encode("space", forKey: .type)
            try container.encode(space, forKey: .space)
        }
    }

    enum CodingKeys: CodingKey {
        case type, space
    }
}
