import Foundation
import SwiftRex

class PendingNotificationsMiddleware: Middleware {
    typealias InputActionType = NotificationAction
    typealias OutputActionType = NotificationAction
    typealias StateType = Void

    lazy var deps: UserNotificationDeps = .default
    var output: AnyActionHandler<NotificationAction>!

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<NotificationAction>) {
        self.output = output
    }

    func handle(action: NotificationAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if action.isGetPending {
            deps.userNotificationCenter.getPendingNotificationRequests { requests in
                self.output.dispatch(.setPending(requests: requests))
            }
        } else if case let .removePending(request) = action {
            let identifiers = [request.uuidString]
            deps.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}
