import SwiftRex

let appReducer = historyReducer.lift(
    action: \AppAction.history as KeyPath<AppAction, HistoryAction?>,
    state: \AppState.history as WritableKeyPath<AppState, HistoryState>
)
