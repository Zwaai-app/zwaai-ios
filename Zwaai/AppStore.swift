import SwiftUI

struct AppState {
    var lock: LockState
    var history: [HistoryItem]
}

class Store: ObservableObject {
    @Published var state = AppState(lock: .locked, history: [])
}

let store = Store()

func dispatch(action: Action) {
    let newState = reducer(store.state, action)
    store.state = newState
}
