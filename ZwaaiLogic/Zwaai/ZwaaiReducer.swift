import Foundation
import SwiftRex

let zwaaiReducer = Reducer<ZwaaiAction, ZwaaiState> { action, state in
    var newState = state
    switch action {
    case .didScan(let url): break // only for middleware

    case .checkin(let space):
        newState.checkedIn = space
    case .checkout(let space):
        if state.checkedIn == space {
            newState.checkedIn = nil
        }
    }
    return newState
}
