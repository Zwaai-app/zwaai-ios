import SwiftUI
import Combine

struct HistoryTab: View {
    @EnvironmentObject var store: Store
    var state: AppState { return store.state }

    var body: some View {
        NavigationView() {
            ZStack {
                HistoryList(history: $store.state.history.entries)
                    .opacity(state.history.lock.isOpen() ? 1 : 0)
                UnlockButton()
                    .disabled(state.history.lock == .unlocking)
                    .opacity(state.history.lock.isOpen() ? 0 : 1)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Geschiedenis")
            .navigationBarItems(leading: ToggleLockButton())
        }
        .tabItem {
            VStack {
                Image(systemName: "clock")
                Text("Geschiedenis")
            }
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
        store.state.history.entries = testData
        return TabView() { HistoryTab().environmentObject(store) }
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

struct HistoryList: View {
    @Binding var history: [HistoryItem]
    var dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()

    var body: some View {
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
        }
    }
}

struct UnlockButton: View {
    var body: some View {
        Button(action: { dispatch(action: .tryUnlock) }) {
            VStack {
                Image(systemName: "lock.shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 20,leading: 100,bottom: 20,trailing: 100))
                    .frame(minWidth: 0, maxWidth: .infinity)
                Text("Toon geschiedenis").font(.title)
            }
        }
    }
}

struct ToggleLockButton: View {
    @EnvironmentObject var store: Store

    var body: some View {
        Button(action: self.toggleLock) {
            HStack {
                Image(systemName: "lock.shield")
                Text(store.state.history.lock.actionString())
            }
        }
    }

    func toggleLock() {
        if store.state.history.lock == .locked {
            dispatch(action: .tryUnlock)
        } else {
            dispatch(action: .lock)
        }
    }
}
