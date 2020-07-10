import Foundation
import SwiftRex

let appMetaReducer = Reducer<AppMetaAction, AppMetaState> { action, state in
    var newState = state
    switch action {
    case .didSaveState(let result):
        newState.lastSaved = result
    case .checkSystemNotificationPermissions: break; // only for middleware
    case .set(let systemNotificationPermission):
        newState.systemNotificationPermission = systemNotificationPermission
    default: break
    }
    return newState
}
