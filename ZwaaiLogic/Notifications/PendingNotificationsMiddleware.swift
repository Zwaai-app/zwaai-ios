import Foundation
import SwiftRex

class PendingNotificationsMiddleware: Middleware {
    typealias InputActionType = AppAction
    typealias OutputActionType = NotificationAction
    typealias StateType = Void

    lazy var deps: UserNotificationDeps = .default
    var output: AnyActionHandler<NotificationAction>!

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<NotificationAction>) {
        self.output = output
    }

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if action.meta?.notification?.isGetPending ?? false {
            deps.userNotificationCenter.getPendingNotificationRequests { requests in
                self.output.dispatch(.setPending(requests: requests))
            }
        } else if case let .meta(.notification(.removePending(request))) = action {
            let identifiers = [request.uuidString]
            deps.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        } else if case let .zwaai(.checkout(space)) = action {
            self.output.dispatch(.removePending(requestId: space.id))
        }
    }
}
