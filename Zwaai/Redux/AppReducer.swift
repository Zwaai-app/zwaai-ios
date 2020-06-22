import SwiftRex

let appReducer
    = historyReducer.lift(action: \AppAction.history, state: \AppState.history)
        <> appMetaReducer.lift(action: \AppAction.meta, state: \AppState.meta)
