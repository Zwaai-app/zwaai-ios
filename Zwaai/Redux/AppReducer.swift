import SwiftRex

let appReducer
    = historyReducer.lift(action: \AppAction.history, state: \AppState.history)
        <> appMetaReducer.lift(action: \AppAction.meta, state: \AppState.meta)
        <> zwaaiReducer.lift(action: \AppAction.zwaai, state: \AppState.zwaai)
        <> resetAppStateReducer
