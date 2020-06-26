import Foundation
import SwiftRex

class DidScanURLMiddleware: Middleware {
    typealias InputActionType = HistoryAction
    typealias OutputActionType = AppAction
    typealias StateType = Void

    var output: AnyActionHandler<AppAction>?

    func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppAction>) {
        self.output = output
    }

    func handle(action: HistoryAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .addEntry(url) = action,
            let item = createItem(from: url) {
            self.output?.dispatch(.history(.addItem(item: item)))
            if case let .space(space) = item.type {
                self.output?.dispatch(.zwaai(.checkin(space: space)))
            }
        }
    }
}

func createItem(from url: URL) -> HistoryItem? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let query = components.queryItems,
        let randomStr = query.first(where: {$0.name == "random"})?.value,
        let random = Random(hexEncoded: randomStr),
        let typeStr = query.first(where: {$0.name == "type"})?.value else {
            return nil

    }

    let type: HistoryZwaaiType
    if typeStr == "space" {
        guard let space = CheckedInSpace(from: url) else { return nil }
        type = .space(space: space)
    } else {
        type = .person
    }
    return HistoryItem(id: UUID(), timestamp: Date(), type: type, random: random)
}
