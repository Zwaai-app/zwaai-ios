import Foundation
import SwiftRex

let zwaaiReducer = Reducer<ZwaaiAction, ZwaaiState> { action, state in
    var newState = state
    switch action {
    case .didScan(let url): break // only for middleware
    case .checkinPending:
        newState.checkedInStatus = .pending
    case .checkinSucceeded(space: let space):
        newState.checkedInStatus = .succeeded(value: space)
    case .checkinFailed(reason: let reason):
        newState.checkedInStatus = .failed(reason: reason)

    case .checkin(let space):
        newState.checkedIn = space
    case .checkout(let space): // TODO: should set checkedInStatus to nil
        if state.checkedIn == space {
            newState.checkedIn = nil
        }
    }
    return newState
}
