import Foundation
import SwiftRex

class PersistStateMiddleware: Middleware {
    typealias InputActionType = AppAction
    typealias OutputActionType = AppAction
    typealias StateType = AppState

    var getState: GetState<AppState>!
    var output: AnyActionHandler<AppAction>!

    func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<AppAction>) {
        self.getState = getState
        self.output = output
    }

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case .meta = action { return }

        afterReducer = .do {
            let saveResult = saveAppState(state: self.getState())
            self.output.dispatch(.meta(.didSaveState(result: saveResult)))
        }
    }
}
