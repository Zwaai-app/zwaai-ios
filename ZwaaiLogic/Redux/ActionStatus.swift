import Foundation

public enum ActionStatus<SuccessValue: Codable & Equatable>: Codable, Equatable {
    case pending
    case succeeded(value: SuccessValue)
    case failed(reason: String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let which = try container.decode(String.self, forKey: .which)
        switch which {
        case "pending":
            self = .pending
        case "succeeded":
            let value = try container.decode(SuccessValue.self, forKey: .value)
            self = .succeeded(value: value)
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
        case .succeeded(let value):
            try container.encode("succeeded", forKey: .which)
            try container.encode(value, forKey: .value)
        case .failed(let reason):
            try container.encode("failed", forKey: .which)
            try container.encode(reason, forKey: .reason)
        }
    }

    enum CodingKeys: CodingKey {
        case which
        case value
        case reason
    }
}
