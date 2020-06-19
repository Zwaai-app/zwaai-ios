import SwiftUI
import Combine
import SwiftRex
import CombineRex

struct HistoryTab: View {
    @ObservedObject var viewModel: ObservableViewModel<HistoryViewModel.ViewAction, HistoryViewModel.ViewState>

    var body: some View {
        ZStack {
            HistoryList(history: $viewModel.state.entries)
                .opacity(viewModel.state.lock.isOpen() ? 1 : 0)
            UnlockButton(viewModel: viewModel)
                .disabled(viewModel.state.lock == .unlocking)
                .opacity(viewModel.state.lock.isOpen() ? 0 : 1)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Geschiedenis")
        .navigationBarItems(leading: ToggleLockButton(viewModel: viewModel))
    }
}

#if DEBUG
struct HistoryTab_Previews: PreviewProvider {
    static var previews: some View {
        let previewData = [
            HistoryItem(id: UUID(), timestamp: Date(), type: .Person),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600), type: .Person),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600*24), type: .Person
            ),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -7200*24), type: .Room)
        ]
        let previewState = HistoryViewModel.ViewState(entries: previewData, lock: .locked)
        let viewModel = ObservableViewModel<
            HistoryViewModel.ViewAction, HistoryViewModel.ViewState>.mock(
                state: previewState,
                action: { action, _, state in
                    switch action {
                    case .lock: state.lock = .locked
                    case .tryUnlock: state.lock = .unlocked
                    }
            })
        return TabView() { HistoryTab(viewModel: viewModel) }
    }
}
#endif

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
    @ObservedObject var viewModel: ObservableViewModel<HistoryViewModel.ViewAction, HistoryViewModel.ViewState>

    var body: some View {
        Button(action: { self.viewModel.dispatch(.tryUnlock) }) {
            VStack {
                Image(systemName: "lock.shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 20,leading: 100,bottom: 20,trailing: 100))
                    .frame(maxWidth: .infinity)
                Text("Toon geschiedenis").font(.title)
            }
        }
    }
}

struct ToggleLockButton: View {
    @ObservedObject var viewModel: ObservableViewModel<HistoryViewModel.ViewAction, HistoryViewModel.ViewState>

    var body: some View {
        Button(action: self.toggleLock) {
            HStack {
                Image(systemName: "lock.shield")
                Text(viewModel.state.lock.actionString())
            }
        }
    }

    func toggleLock() {
        if viewModel.state.lock == .locked {
            viewModel.dispatch(.tryUnlock)
        } else {
            viewModel.dispatch(.lock)
        }
    }
}


enum HistoryViewModel {
    static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    enum ViewAction {
        case lock
        case tryUnlock
    }

    struct ViewState: Equatable {
        var entries: [HistoryItem]
        var lock: LockState
        static let empty: ViewState = transform(appState: initialAppState)

    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .lock: return .history(.lock)
        case .tryUnlock: return .history(.tryUnlock)
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(entries: appState.history.entries, lock: appState.history.lock)
    }
}
