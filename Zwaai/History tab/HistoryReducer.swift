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
            let typeStr = query.first(where: {$0.name == "type"})?.value {

            let type: HistoryZwaaiType
            if typeStr == "space" {
                guard let space = CheckedInSpace(from: url) else { break }
                type = .space(space: space)
            } else {
                type = .person
            }
            let item = HistoryItem(id: UUID(), timestamp: Date(), type: type, random: random)
            switch type {
            case .person: newState.allTimePersonZwaaiCount += 1
            case .space: newState.allTimeSpaceZwaaiCount += 1
            }
            newState.entries.insert(item, at: 0)
        }

    #if DEBUG
    case .addTestItem(let item):
        newState.entries.append(item)
        switch item.type {
        case .person: newState.allTimePersonZwaaiCount += 1
        case .space: newState.allTimeSpaceZwaaiCount += 1
        }
    #endif
    }
    return newState
}
