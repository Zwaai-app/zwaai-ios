import SwiftRex

#if DEV_MODE
let loggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = LoggerMiddleware().lift(outputActionMap: absurd).eraseToAnyMiddleware()
#else
let loggerMiddleware
    = IdentityMiddleware<AppAction, AppAction, AppState>().eraseToAnyMiddleware()
#endif

let didScanURLMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = DidScanURLMiddleware().lift(stateMap: ignore).eraseToAnyMiddleware()

let updateHistoryOnCheckoutMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = UpdateHistoryOnCheckoutMiddleware().lift(
        inputActionMap: \AppAction.zwaai,
        outputActionMap: AppAction.history,
        stateMap: ignore).eraseToAnyMiddleware()

let onlyOneSpaceCheckedInAtTheTimeMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = OnlyOneSpaceCheckedInAtTheTimeMiddleware().lift(
        inputActionMap: \AppAction.zwaai,
        outputActionMap: AppAction.history).eraseToAnyMiddleware()

let autoCheckoutMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = AutoCheckoutMiddleware().lift(
        outputActionMap: AppAction.zwaai,
        stateMap: { $0.zwaai }).eraseToAnyMiddleware()

let unitTestSafeAppMiddleware
    =  autoCheckoutMiddleware
        <> updateHistoryOnCheckoutMiddleware
        <> onlyOneSpaceCheckedInAtTheTimeMiddleware

let zwaaiFeedbackMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = ZwaaiFeedbackMiddleware().lift(
        inputActionMap: \AppAction.meta,
        outputActionMap: absurd,
        stateMap: ignore).eraseToAnyMiddleware()

let checkNotificationsMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = CheckSystemNotificationPermissionsMiddleware().lift(
        inputActionMap: \AppAction.meta,
        outputActionMap: AppAction.meta,
        stateMap: ignore
    ).eraseToAnyMiddleware()

let pendingNotificationsMiddleware: AnyMiddleware<AppAction, AppAction, AppState>
    = PendingNotificationsMiddleware().lift(
        outputActionMap: { action in return .meta(.notification(action: action)) },
        stateMap: ignore
    ).eraseToAnyMiddleware()

public let appMiddleware =
    // `PersistStateMiddleware` must come first, so that it's `afterReducer` is
    // last so all middlewares are done when saving
    PersistStateMiddleware()
        <> AuthenticateMiddleware()
        <> checkNotificationsMiddleware
        <> pendingNotificationsMiddleware
        <> unitTestSafeAppMiddleware
        <> didScanURLMiddleware
        <> zwaaiFeedbackMiddleware
        <> loggerMiddleware
