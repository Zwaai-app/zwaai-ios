import Foundation
import UIKit
import UserNotifications

public enum AppMetaAction: Equatable, Prism {
    case didSaveState(result: Result<Date, AppError>)
    case zwaaiSucceeded(presentingController: UIViewController, onDismiss: () -> Void)
    case zwaaiFailed(presentingController: UIViewController, onDismiss: () -> Void)
    case setupAutoCheckout
    case notification(action: NotificationAction)

    public static func == (lhs: AppMetaAction, rhs: AppMetaAction) -> Bool {
        switch(lhs, rhs) {
        case (.didSaveState(let lhsResult), .didSaveState(let rhsResult)):
            return lhsResult == rhsResult
        case (.zwaaiSucceeded(let lhsController, _), .zwaaiSucceeded(let rhsController, _)):
            return lhsController == rhsController
        case (.zwaaiFailed(let lhsController, _), .zwaaiFailed(let rhsController, _)):
            return lhsController == rhsController
        case (.setupAutoCheckout, .setupAutoCheckout):
            return true
        case (.notification(let lhsAction), .notification(let rhsAction)):
            return lhsAction == rhsAction
        default:
            return false
        }
    }
}

public enum NotificationAction: Equatable, Prism {
    case checkSystemPermissions
    case set(systemPermission: UNAuthorizationStatus)
    case getPending
    case setPending(requests: [UNNotificationRequest])
    case removePending(requestId: UUID)
}
