import SwiftRex

#if DEBUG
let loggerMiddleware = LoggerMiddleware()
#else
let loggerMiddleware = IdentityMiddleware<AppAction, AppAction, AppState>()
#endif

let liftedLoggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = loggerMiddleware.lift(outputActionMap: absurd).eraseToAnyMiddleware()

let liftedDidScanURLMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = DidScanURLMiddleware().lift(
        inputActionMap: \AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let liftedUpdateHistoryOnCheckoutMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = UpdateHistoryOnCheckoutMiddleware().lift(
        inputActionMap: \AppAction.zwaai,
        outputActionMap: AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let appMiddleware =
    // `PersistStateMiddleware` must come first, so that it's `afterReducer` is
    // last so all middlewares are done when saving
    PersistStateMiddleware()
        <> AuthenticateMiddleware()
        <> liftedDidScanURLMiddleware
        <> liftedUpdateHistoryOnCheckoutMiddleware
        <> liftedLoggerMiddleware

// swiftlint:disable identifier_name
func ignore<T>(_ t: T) { }
func absurd<A>(_ never: Never) -> A {}
