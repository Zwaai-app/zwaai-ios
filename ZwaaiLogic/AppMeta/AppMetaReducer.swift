import Foundation
import SwiftRex

let appMetaReducer = Reducer<AppMetaAction, AppMetaState> { action, state in
    var newState = state
    switch action {
    case .didSaveState(let result):
        newState.lastSaved = result
    case .zwaaiSucceeded:
        // used for giving audio/haptic feedback
        break
    case .zwaaiFailed:
        // used for giving audio/haptic feedback
        break
    case .setupAutoCheckout:
        // used for triggering middleware on app activation (setup timers)
        break

    case .notification(let action):
        newState = notificationReducer.reduce(action, newState)

    case .setFeedbackContinuation(let continuation):
        newState.feedbackContinuation = continuation

    case .clearFeedbackContinuation:
        newState.feedbackContinuation = nil
    }

    return newState
}

let notificationReducer = Reducer<NotificationAction, AppMetaState> { action, state in
    var newState = state
    switch action {
    case .checkSystemPermissions:
        // used to trigger middleware that checks system permissions
        break
    case .set(let systemNotificationPermission):
        newState.systemNotificationPermission = systemNotificationPermission
    case .getPending:
        // used to trigger middleware that gets pending notifications from system
        break
    case .setPending(let requests):
        newState.pendingNotifications = requests.compactMap { UUID(uuidString: $0.identifier) }
    case .removePending(let requestId):
        newState.pendingNotifications.removeAll { $0 == requestId }
    }
    return newState
}
