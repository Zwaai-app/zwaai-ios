import SwiftUI
import Combine

struct AppState {
    var lock: LockState
}

class Store: ObservableObject {
    @Published var state = AppState(lock: .locked)
}

let store = Store()

enum LockState {
    case locked
    case unlocking
    case unlocked

    mutating func toggle() {
        if self == .locked {
            self = .unlocking
        } else if self == .unlocked {
            self = .locked
        }
    }

    func actionString() -> String {
        switch (self) {
        case .locked: return "Toon"
        case .unlocked: return "Verberg"
        case .unlocking: return "..."
        }
    }

    func isOpen() -> Bool { return self == .unlocked }

    mutating func unlockSucceeded() {
        self = .unlocked
    }
}

enum Action {
    case lock
    case tryUnlock
    case unlockSucceeded
    case unlockFailed
}

func reducer(_ state: AppState, _ action: Action) -> AppState {
    var newState = state
    switch action {
    case .lock: newState.lock = .locked
    case .tryUnlock:
        newState.lock = .unlocking
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            dispatch(action: .unlockSucceeded)
        }
    case .unlockFailed: newState.lock = .locked
    case .unlockSucceeded: newState.lock = .unlocked
    }
    return newState
}

func dispatch(action: Action) {
    let newState = reducer(store.state, action)
    store.state = newState
}

struct HistoryTab: View {
    var history: [HistoryItem]
    @ObservedObject var store: Store
    var state: AppState { return store.state }

    var dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()

    var body: some View {
        NavigationView() {
            ZStack {
                List() {
                    Section(header: PersonenHeader()) {
                        ForEach(history.filter({$0.type == .Person})) {item in
                            Text(self.dateFormatter.string(from: item.timestamp))
                        }
                    }
                    Section(header: RoomsHeader()) {
                        ForEach(history.filter({$0.type == .Room})) {item in
                            Text(self.dateFormatter.string(from: item.timestamp))
                        }
                    }
                }.opacity(state.lock.isOpen() ? 1 : 0)
                Button(action: self.toggleLock) {
                    VStack {
                        Image(systemName: "lock.shield")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(EdgeInsets(top: 20,leading: 100,bottom: 20,trailing: 100))
                            .frame(minWidth: 0, maxWidth: .infinity)
                        Text("Toon geschiedenis").font(.title)
                    }
                }
                .disabled(state.lock == .unlocking)
                .opacity(state.lock.isOpen() ? 0 : 1)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Geschiedenis")
            .navigationBarItems(leading: Button(action: self.toggleLock) {
                HStack {
                    Image(systemName: "lock.shield")
                    Text(state.lock.actionString())
                }
            })
        }
        .tabItem {
            VStack {
                Image(systemName: "clock")
                Text("Geschiedenis")
            }
        }
    }

    func toggleLock() {
        if state.lock == .locked {
            dispatch(action: .tryUnlock)
        } else {
            dispatch(action: .lock)
        }
    }

}

struct HistoryTab_Previews: PreviewProvider {
    static var previews: some View {
        let testData = [
            HistoryItem(id: UUID(), timestamp: Date(), type: .Person),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600), type: .Person),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600*24), type: .Person
            ),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -7200*24), type: .Room)
        ]
        return TabView() { HistoryTab(history: testData, store: store) }
    }
}

struct PersonenHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            Text("Gezwaaid met personen").font(.subheadline)
        }
    }
}

struct RoomsHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text("Gezwaaid bij ruimtes").font(.subheadline)
        }
    }
}

enum ZwaaiType {
    case Person
    case Room
}

struct HistoryItem: Identifiable {
    let id: UUID
    let timestamp: Date
    let type: ZwaaiType
}
