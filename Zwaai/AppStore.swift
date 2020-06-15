import SwiftUI

class Store: ObservableObject {
    @Published var state = AppState(history: HistoryState(lock: .locked, entries: []))
}

let store = Store()

func dispatch(action: Action) {
    let newState = reducer(store.state, action)
    store.state = newState
}
