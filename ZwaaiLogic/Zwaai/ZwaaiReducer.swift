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

    case .checkout(let space):
        if let status = state.checkedInStatus,
            status == .succeeded(value: space) || status.isFailed
        {
            newState.checkedInStatus = nil
        }
    }
    return newState
}
