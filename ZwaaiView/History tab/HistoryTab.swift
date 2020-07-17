import SwiftUI
import Combine
import SwiftRex
import CombineRex
import ZwaaiLogic

struct HistoryTab: View {
    @ObservedObject var viewModel: ObservableViewModel<HistoryViewModel.ViewAction, HistoryViewModel.ViewState>

    var body: some View {
        ZStack {
            HistoryList(personItems: $viewModel.state.personItems,
                        spaceItems: $viewModel.state.spaceItems,
                        allTimePersonZwaaiCount: $viewModel.state.personCount,
                        allTimeSpaceZwaaiCount: $viewModel.state.spaceCount)
                .listStyle(GroupedListStyle())
                .opacity(viewModel.state.lock.isOpen() ? 1 : 0)
            UnlockButton(viewModel: viewModel)
                .disabled(viewModel.state.lock == .unlocking)
                .opacity(viewModel.state.lock.isOpen() ? 0 : 1)
                .accessibility(hidden: viewModel.state.lock.isOpen())
        }
        .navigationBarTitle("Geschiedenis")
        .navigationBarItems(leading: ToggleLockButton(viewModel: viewModel))
    }
}

#if DEBUG
struct HistoryTab_Previews: PreviewProvider {
    static var previews: some View {
        let space = CheckedInSpace(
            name: "Test Space",
            description: "Somewhere in the universe",
            autoCheckout: 3600
        )
        let personItems = [
            HistoryItem(id: UUID(), timestamp: Date(), type: .person, random: Random())
        ]
        let spaceItems = [
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600), type: .person, random: Random()),
            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -3600*24), type: .person, random: Random()),

            HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -7200*24),
                        type: .space(space: space), random: Random())
        ]
        let previewState = HistoryViewModel.ViewState(
            personItems: personItems,
            spaceItems: spaceItems,
            lock: .unlocked,
            personCount: 3,
            spaceCount: 1)
        let viewModel = ObservableViewModel<
            HistoryViewModel.ViewAction, HistoryViewModel.ViewState>.mock(
                state: previewState,
                action: { action, _, state in
                    switch action {
                    case .lock: state.lock = .locked
                    case .tryUnlock: state.lock = .unlocked
                    }
            })
        return TabView { HistoryTab(viewModel: viewModel) }
    }
}
#endif

struct UnlockButton: View {
    @ObservedObject var viewModel: ObservableViewModel<HistoryViewModel.ViewAction, HistoryViewModel.ViewState>

    var body: some View {
        // swiftlint:disable:next multiple_closures_with_trailing_closure
        Button(action: { self.viewModel.dispatch(.tryUnlock) }) {
            VStack {
                Image(systemName: "lock.shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 20, leading: 100, bottom: 20, trailing: 100))
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
