import Foundation

private let timestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "nl_NL")
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct AppMetaState: CustomStringConvertible {
    var lastSaved: Result<Date, AppError>?

    var description: String {
        guard let lastSaved = lastSaved else {
            return "---"
        }
        switch lastSaved {
        case .success(let date):
            return timestampFormatter.string(from: date)
        case .failure(let error):
            return "[error] Failed to save state: " + error.localizedDescription
        }
    }
}
