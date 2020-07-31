import Foundation
import SwiftRex
import Combine

public class OnlyOneSpaceCheckedInAtTheTimeMiddleware: Middleware {
    public typealias InputActionType = ZwaaiAction
    public typealias OutputActionType = HistoryAction
    public typealias StateType = AppState

    var output: AnyActionHandler<HistoryAction>?
    var getState: GetState<AppState>?

    public func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<HistoryAction>) {
        self.getState = getState
        self.output = output
    }

    public func handle(action: ZwaaiAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        guard let appState = getState?() else { return }

        if action.isCheckinPending, let space = appState.zwaai.checkedInStatus?.succeeded {
            output?.dispatch(.setCheckedOut(space: space))
        }
    }
}
