import Foundation
import SwiftRex

let resetAppStateReducer = Reducer<AppAction, AppState> { action, state in
    if case .resetAppState = action {
        return initialAppState
    } else {
        return state
    }
}
