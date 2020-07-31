import Foundation
import UIKit
import UserNotifications

public struct AppMetaState: Equatable, CustomStringConvertible {
    public var lastSaved: Result<Date, AppError>?
    public var systemNotificationPermission: UNAuthorizationStatus?
    public var pendingNotifications: [UUID] = []
    public var feedbackContinuation: FeedbackContinuation?

    public var description: String {
        return "{lastSaved: \(lastSavedDescription)"
            + ", systemNotificationPermission: \(String(describing: systemNotificationPermission))"
            + ", pendingNotifications: \(pendingNotifications)"
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

extension UNAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "not determined"
        case .provisional: return "provisional"
        default: return String(rawValue)
        }
    }
}

public struct FeedbackContinuation: Equatable {
    public var url: ZwaaiURL
    public weak var presentingController: UIViewController?
    public var onDismiss: () -> Void

    public static func == (lhs: FeedbackContinuation, rhs: FeedbackContinuation) -> Bool {
        return lhs.url == rhs.url && lhs.presentingController == rhs.presentingController
    }
}
