import Foundation
import SwiftRex
import Combine

public class UpdateHistoryOnCheckoutMiddleware: Middleware {
    public typealias InputActionType = ZwaaiAction
    public typealias OutputActionType = HistoryAction
    public typealias StateType = Void

    var output: AnyActionHandler<HistoryAction>?

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<HistoryAction>) {
        self.output = output
    }

    public func handle(action: ZwaaiAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .checkout(space) = action {
            output?.dispatch(.setCheckedOut(space: space))
        }
    }
}
