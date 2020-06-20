import Foundation
import SwiftRex

let historyReducer = Reducer<HistoryAction, HistoryState> { action, state in
    var newState = state
    switch action {
    case .lock:
        newState.lock = .locked
    case .unlockFailed:
        newState.lock = .locked
    case .unlockSucceeded:
        newState.lock = .unlocked
    case .tryUnlock:
        newState.lock = .unlocking

    case .addEntry(let url):
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let query = components.queryItems,
            let randomStr = query.first(where: {$0.name == "random"})?.value,
            let random = Random(hexEncoded: randomStr),
            let typeStr = query.first(where: {$0.name == "type"})?.value,
            let type = ZwaaiType(rawValue: typeStr) {
            let item = HistoryItem(id: UUID(), timestamp: Date(), type: type, random: random)
            newState.entries.append(item)
        }
    }
    return newState
}
