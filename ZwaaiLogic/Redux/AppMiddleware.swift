import SwiftRex

#if DEV_MODE
let loggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = LoggerMiddleware().lift(outputActionMap: absurd).eraseToAnyMiddleware()
#else
let loggerMiddleware
    = IdentityMiddleware<AppAction, AppAction, AppState>().eraseToAnyMiddleware()
#endif

let didScanURLMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = DidScanURLMiddleware().lift(
        inputActionMap: \AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let updateHistoryOnCheckoutMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = UpdateHistoryOnCheckoutMiddleware().lift(
        inputActionMap: \AppAction.zwaai,
        outputActionMap: AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let unitTestSafeAppMiddleware
    = didScanURLMiddleware
        <> updateHistoryOnCheckoutMiddleware

public let appMiddleware =
    // `PersistStateMiddleware` must come first, so that it's `afterReducer` is
    // last so all middlewares are done when saving
    PersistStateMiddleware()
        <> AuthenticateMiddleware()
        <> unitTestSafeAppMiddleware
        <> loggerMiddleware
