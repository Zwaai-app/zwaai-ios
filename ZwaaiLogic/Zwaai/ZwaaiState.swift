import Foundation

public struct ZwaaiState: Codable, CustomStringConvertible, Equatable {
    public var checkedIn: CheckedInSpace?

    public var description: String {
        guard let space = checkedIn else {
            return "not checked in"
        }
        return "Checked in: \(space)"
    }
}

public enum CheckedInState: Codable, Equatable {
    case pending
    case succeeded(space: CheckedInSpace)
    case failed(reason: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let which = try container.decode(String.self, forKey: .which)
        switch which {
        case "pending":
            self = .pending
        case "succeeded":
            let space = try container.decode(CheckedInSpace.self, forKey: .space)
            self = .succeeded(space: space)
        case "failed":
            let reason = try container.decode(String.self, forKey: .reason)
            self = .failed(reason: reason)
        default:
            throw AppError.decodeFailure(error: nil)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending:
            try container.encode("pending", forKey: .which)
        case .succeeded(let space):
            try container.encode("succeeded", forKey: .which)
            try container.encode(space, forKey: .space)
        case .failed(let reason):
            try container.encode("failed", forKey: .which)
            try container.encode(reason, forKey: .reason)
        }
    }

    enum CodingKeys: CodingKey {
        case which
        case space
        case reason
    }
}

let initialZwaaiState = ZwaaiState(checkedIn: nil)
