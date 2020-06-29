import Foundation

public struct AppMetaState: CustomStringConvertible {
    public var lastSaved: Result<Date, AppError>?

    public var description: String {
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
