import Foundation
import SwiftRex

class PersistStateMiddleware: Middleware {
    typealias InputActionType = AppAction
    typealias OutputActionType = Never
    typealias StateType = AppState

    var getState: GetState<AppState>!

    func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<Never>) {
        self.getState = getState

    }

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        afterReducer = .do {
            saveAppState(state: self.getState())
        }
    }
}
