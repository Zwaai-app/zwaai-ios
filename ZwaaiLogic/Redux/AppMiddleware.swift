import SwiftRex

#if DEBUG
let loggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = LoggerMiddleware().lift(outputActionMap: absurd).eraseToAnyMiddleware()
#else
let loggerMiddleware
    = IdentityMiddleware<AppAction, AppAction, AppState>().eraseToAnyMiddleware()
#endif

let liftedLoggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = loggerMiddleware

let liftedDidScanURLMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = DidScanURLMiddleware().lift(
        inputActionMap: \AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let liftedUpdateHistoryOnCheckoutMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = UpdateHistoryOnCheckoutMiddleware().lift(
        inputActionMap: \AppAction.zwaai,
        outputActionMap: AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

public let appMiddleware =
    // `PersistStateMiddleware` must come first, so that it's `afterReducer` is
    // last so all middlewares are done when saving
    PersistStateMiddleware()
        <> AuthenticateMiddleware()
        <> liftedDidScanURLMiddleware
        <> liftedUpdateHistoryOnCheckoutMiddleware
        <> liftedLoggerMiddleware
