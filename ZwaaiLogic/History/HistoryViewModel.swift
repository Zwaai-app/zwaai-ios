import SwiftRex
import CombineRex

public enum HistoryViewModel {
    public static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    public enum ViewAction {
        case lock
        case tryUnlock
    }

    public struct ViewState: Equatable {
        public var personItems: [HistoryItem]
        public var spaceItems: [HistoryItem]
        public var lock: LockState
        public var personCount: UInt
        public var spaceCount: UInt

        public init(personItems: [HistoryItem], spaceItems: [HistoryItem], lock: LockState, personCount: UInt, spaceCount: UInt) {
            self.personItems = personItems
            self.spaceItems = spaceItems
            self.lock = lock
            self.personCount = personCount
            self.spaceCount = spaceCount
        }

        public static let empty: ViewState = ViewState(
            personItems: [], spaceItems: [], lock: .unlocked,
            personCount: 0, spaceCount: 0)
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .lock: return .history(.lock)
        case .tryUnlock: return .history(.tryUnlock)
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(
            personItems: appState.history.entries.lazy.filter { $0.type.isPerson },
            spaceItems: appState.history.entries.lazy.filter { $0.type.isSpace },
            lock: appState.history.lock,
            personCount: appState.history.allTimePersonZwaaiCount,
            spaceCount: appState.history.allTimeSpaceZwaaiCount
        )
    }
}
