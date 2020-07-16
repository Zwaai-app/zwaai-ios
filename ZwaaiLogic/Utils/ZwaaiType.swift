import Foundation

public enum ZwaaiType: Codable, Equatable, Prism {
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
            let error = AppError.invalidZwaaiType(type: type)
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
