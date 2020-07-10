import SwiftRex

public let appReducer
    = historyReducer.lift(action: \AppAction.history, state: \AppState.history)
        <> appMetaReducer.lift(action: \AppAction.meta, state: \AppState.meta)
        <> zwaaiReducer.lift(action: \AppAction.zwaai, state: \AppState.zwaai)
        <> settingsReducer.lift(action: \AppAction.settings, state: \AppState.settings)
        <> resetAppStateReducer
