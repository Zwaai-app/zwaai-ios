import SwiftRex
import CombineRex

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
        var personCount: UInt
        var roomCount: UInt

        static let empty: ViewState = ViewState(
            entries: [], lock: .unlocked,
            personCount: 0, roomCount: 0)
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .lock: return .history(.lock)
        case .tryUnlock: return .history(.tryUnlock)
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(
            entries: appState.history.entries,
            lock: appState.history.lock,
            personCount: appState.history.allTimePersonZwaaiCount,
            roomCount: appState.history.allTimeRoomZwaaiCount
        )
    }
}
