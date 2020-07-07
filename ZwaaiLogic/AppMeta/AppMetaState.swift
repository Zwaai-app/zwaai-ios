import Foundation

public struct AppMetaState: Equatable, CustomStringConvertible {
    public var lastSaved: Result<Date, AppError>?

    public var description: String {
        return "{lastSaved: \(lastSavedDescription)"
            + "}"
    }

    var lastSavedDescription: String {
        guard let lastSaved = lastSaved else {
            return "---"
        }
        switch lastSaved {
        case .success(let date):
            return DateFormatter.shortNL.string(from: date)
        case .failure(let error):
            return "[error] Failed to save state: " + error.localizedDescription
        }
    }
}

let initialMetaState = AppMetaState()
