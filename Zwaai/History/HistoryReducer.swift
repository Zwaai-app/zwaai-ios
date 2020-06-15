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
    }
    return newState
}
