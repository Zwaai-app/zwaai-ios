import Foundation
import SwiftRex

let zwaaiReducer = Reducer<ZwaaiAction, ZwaaiState> { action, state in
    var newState = state
    switch action {
    case .checkin(let space):
        newState.checkedIn = space
    case .checkout: newState.checkedIn = nil
    }
    return newState
}
