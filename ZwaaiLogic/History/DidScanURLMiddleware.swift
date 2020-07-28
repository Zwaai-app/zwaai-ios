import Foundation
import SwiftRex

public class DidScanURLMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = AppAction
    public typealias StateType = Void

    var output: AnyActionHandler<AppAction>?

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppAction>) {
        self.output = output
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if let url = action.zwaai?.didScan {
            let item = HistoryItem(
                id: UUID(),
                timestamp: Date(),
                type: url.type)
            self.output?.dispatch(.history(.addItem(item: item)))
        } else if let item = action.history?.addItem {
            if case let .space(space) = item.type {
                self.output?.dispatch(.zwaai(.checkin(space: space)))
            }
        }
    }
}
