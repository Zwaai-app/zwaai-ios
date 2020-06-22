import SwiftRex

#if DEBUG
let loggerMiddleware = LoggerMiddleware()
#else
let loggerMiddleware = IdentityMiddleware<AppAction, AppAction, AppState>()
#endif

func absurd<A>(_ never: Never) -> A {}

let liftedLoggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = loggerMiddleware.lift(outputActionMap: absurd).eraseToAnyMiddleware()

let appMiddleware =
    PersistStateMiddleware()
        <> AuthenticateMiddleware()
        <> liftedLoggerMiddleware
