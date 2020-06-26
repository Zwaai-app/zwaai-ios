import Foundation
import SwiftRex
import Combine

class UpdateHistoryOnCheckoutMiddleware: Middleware {
    typealias InputActionType = ZwaaiAction
    typealias OutputActionType = HistoryAction
    typealias StateType = Void

    var output: AnyActionHandler<HistoryAction>?

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<HistoryAction>) {
        self.output = output
    }

    func handle(action: ZwaaiAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .checkout(space) = action {
            output?.dispatch(.setCheckedOut(space: space))
        }
    }
}
