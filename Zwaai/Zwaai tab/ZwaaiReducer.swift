import Foundation
import SwiftRex

let zwaaiReducer = Reducer<ZwaaiAction, ZwaaiState> { action, state in
    var newState = state
    switch action {
    case .didScan(let url):
        if let space = CheckedInSpace(from: url) {
            newState.checkedIn = space
        }
    case .checkout: newState.checkedIn = nil
    }
    return newState
}
