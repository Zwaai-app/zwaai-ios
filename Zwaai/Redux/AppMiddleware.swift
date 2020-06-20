import SwiftRex

#if DEBUG
let loggerMiddleware = LoggerMiddleware()
#else
let loggerMiddleware = IdentityMiddleware<AppAction, AppAction, AppState>()
#endif

let appMiddleware =
    AuthenticateMiddleware() <> loggerMiddleware
