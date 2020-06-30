import Foundation
import SwiftRex

public class PersistStateMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = AppAction
    public typealias StateType = AppState

    var getState: GetState<AppState>!
    var output: AnyActionHandler<AppAction>!
    var persistState: (AppState) -> Result<Date, AppError> = saveAppState(state:)

    public func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<AppAction>) {
        self.getState = getState
        self.output = output
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case .meta = action { return }

        afterReducer = .do {
            let saveResult = self.persistState(self.getState())
            self.output.dispatch(.meta(.didSaveState(result: saveResult)))
        }
    }
}
