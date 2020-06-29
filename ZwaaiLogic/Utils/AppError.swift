public enum AppError: Error, Equatable {
    case noUserDocumentsDirectory
    case decodeStateFailure(error: Error)
    case encodeStateFailure(error: Error)
    case invalidHistoryZwaaiType(type: String)

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch lhs {
        case .noUserDocumentsDirectory: return rhs == .noUserDocumentsDirectory
        case .decodeStateFailure(let lhsError):
            if case let .decodeStateFailure(rhsError) = rhs {
                return lhsError.localizedDescription == rhsError.localizedDescription
            } else {
                return false
            }
        case .encodeStateFailure(let lhsError):
            if case let .encodeStateFailure(rhsError) = rhs {
                return lhsError.localizedDescription == rhsError.localizedDescription
            } else {
                return false
            }
        case .invalidHistoryZwaaiType(let lhsType):
            if case let .invalidHistoryZwaaiType(rhsType) = rhs {
                return lhsType == rhsType
            } else {
                return false
            }
        }
    }
}
