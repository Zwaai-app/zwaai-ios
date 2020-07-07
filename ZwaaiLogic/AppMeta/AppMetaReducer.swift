import Foundation
import SwiftRex

let appMetaReducer = Reducer<AppMetaAction, AppMetaState> { action, state in
    var newState = state
    switch action {
    case .didSaveState(let result):
        newState.lastSaved = result
    default: break
    }
    return newState
}
