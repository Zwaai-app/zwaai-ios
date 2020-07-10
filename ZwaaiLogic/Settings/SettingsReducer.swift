import Foundation
import SwiftRex

let settingsReducer = Reducer<SettingsAction, SettingsState> { action, state in
    var newState = state
    switch action {
    case .set(let notificationPermission):
        guard notificationPermission != .undecided else { break }
        newState.notificationPermission = notificationPermission
    }
    return newState
}
