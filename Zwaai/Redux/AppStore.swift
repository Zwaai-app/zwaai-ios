import SwiftRex
import CombineRex

let appStore = ReduxStoreBase<AppAction, AppState>(
    subject: .combine(initialValue: initialAppState),
    reducer: appReducer,
    middleware: appMiddleware
)
