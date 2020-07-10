import Foundation
import SwiftRex

class CheckSystemNotificationPermissionsMiddleware: Middleware {
    typealias InputActionType = AppMetaAction
    typealias OutputActionType = AppMetaAction
    typealias StateType = Void

    lazy var deps: UserNotificationDeps = .default
    var output: AnyActionHandler<AppMetaAction>!

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppMetaAction>) {
        self.output = output
    }

    func handle(action: AppMetaAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        guard action.isCheckSystemNotificationPermissions else { return }

        deps.userNotificationCenter.getNotificationSettingsTestable { settings in
            self.output.dispatch(.set(systemNotificationPermission: settings.authorizationStatus))
        }
    }
}
