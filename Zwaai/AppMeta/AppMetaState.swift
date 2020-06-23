import Foundation

struct AppMetaState: CustomStringConvertible {
    var lastSaved: Result<Date, AppError>?

    var description: String {
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
