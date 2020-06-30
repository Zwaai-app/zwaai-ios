import Foundation
import SwiftRex

let resetAppStateReducer = Reducer<AppAction, AppState> { action, state in
    return action == .resetAppState ? initialAppState : state
}
