enum AppError: Error {
    case noUserDocumentsDirectory
    case decodeStateFailure(error: Error)
    case encodeStateFailure(error: Error)
}