import Foundation
import UIKit

// sourcery: Prism
public enum AppMetaAction: Equatable {
    case didSaveState(result: Result<Date, AppError>)
    case zwaaiSucceeded(presentingController: UIViewController, onDismiss: () -> Void)
    case zwaaiFailed(presentingController: UIViewController, onDismiss: () -> Void)
    case setupAutoCheckout

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
        default:
            return false
        }
    }
}
