import Foundation
import UserNotifications

public struct AppMetaState: Equatable, CustomStringConvertible {
    public var lastSaved: Result<Date, AppError>?
    public var systemNotificationPermission: UNAuthorizationStatus?

    public var description: String {
        return "{lastSaved: \(lastSavedDescription)"
            + ", systemNotificationPermission: \(String(describing: systemNotificationPermission))"
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
