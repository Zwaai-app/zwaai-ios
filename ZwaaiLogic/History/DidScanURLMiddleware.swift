import Foundation
import SwiftRex

public class DidScanURLMiddleware: Middleware {
    public typealias InputActionType = HistoryAction
    public typealias OutputActionType = AppAction
    public typealias StateType = Void

    var output: AnyActionHandler<AppAction>?

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppAction>) {
        self.output = output
    }

    public func handle(action: HistoryAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .addEntry(url) = action {
            let item = HistoryItem(
                id: UUID(),
                timestamp: Date(),
                type: url.type,
                random: url.random)
            self.output?.dispatch(.history(.addItem(item: item)))
        } else if case let .addItem(item) = action {
            if case let .space(space) = item.type {
                self.output?.dispatch(.zwaai(.checkin(space: space)))
            }
        }
    }
}
