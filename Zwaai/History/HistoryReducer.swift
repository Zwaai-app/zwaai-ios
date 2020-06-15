import Foundation

func historyReducer(_ state: AppState, _ action: HistoryAction) -> AppState {
    var newState = state
    switch action {
    case .lock: newState.history.lock = .locked
    case .tryUnlock:
        newState.history.lock = .unlocking
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            dispatch(action: .unlockSucceeded)
        }
    case .unlockFailed: newState.history.lock = .locked
    case .unlockSucceeded: newState.history.lock = .unlocked
    }
    return newState
}

