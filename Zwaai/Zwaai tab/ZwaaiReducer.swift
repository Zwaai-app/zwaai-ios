import Foundation
import SwiftRex

let zwaaiReducer = Reducer<ZwaaiAction, ZwaaiState> { action, state in
    var newState = state
    switch action {
    case .checkin(let space):
        newState.checkedIn = space
    case .checkout(let space):
        if state.checkedIn == space {
            newState.checkedIn = nil
        }
    }
    return newState
}
