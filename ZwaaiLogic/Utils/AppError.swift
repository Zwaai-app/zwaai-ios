public enum AppError: Error, Equatable, Prism {
    case noUserDocumentsDirectory
    case decodeStateFailure(error: Error)
    case encodeStateFailure(error: Error)
    case invalidZwaaiType(type: String)

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.noUserDocumentsDirectory, .noUserDocumentsDirectory): return true
        case let (.decodeStateFailure(lhsError), .decodeStateFailure(error: rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.encodeStateFailure(lhsError), .encodeStateFailure(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.invalidZwaaiType(lhsType), .invalidZwaaiType(rhsType)):
            return lhsType == rhsType
        default:
            return false
        }
    }
}
