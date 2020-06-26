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

    case .addEntry(let url): break

    case .addItem(let item):
        switch item.type {
        case .person: newState.allTimePersonZwaaiCount += 1
        case .space: newState.allTimeSpaceZwaaiCount += 1
        }
        newState.entries.insert(item, at: 0)

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
