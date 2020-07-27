public enum AppError: Error, Equatable, Prism {
    case noUserDocumentsDirectory
    case decodeFailure(error: Error?)
    case encodeFailure(error: Error?)
    case invalidZwaaiType(type: String)

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.noUserDocumentsDirectory, .noUserDocumentsDirectory): return true
        case let (.decodeFailure(lhsError), .decodeFailure(error: rhsError)):
            return isSameError(lhsError, rhsError)
        case let (.encodeFailure(lhsError), .encodeFailure(rhsError)):
            return isSameError(lhsError, rhsError)
        case let (.invalidZwaaiType(lhsType), .invalidZwaaiType(rhsType)):
            return lhsType == rhsType
        default:
            return false
        }
    }
}

private func isSameError(_ lhs: Error?, _ rhs: Error?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil): return true
    case (.some(let lErr), .some(let rErr)):
        return lErr.localizedDescription == rErr.localizedDescription
    default: return false
    }
}
