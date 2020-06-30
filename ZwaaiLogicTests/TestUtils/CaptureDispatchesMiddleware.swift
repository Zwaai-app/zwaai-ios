import SwiftRex
@testable import ZwaaiLogic

class CaptureDispatchesMiddleware: Middleware {
    typealias InputActionType = AppAction
    typealias OutputActionType = AppAction
    typealias StateType = Void

    var observedActions = [AppAction]()
    var output: AnyActionHandler<AppAction>!

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppAction>) {
        self.output = output
    }

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        self.observedActions.append(action)
    }
}
