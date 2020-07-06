import Foundation
import SwiftRex
import CombineRex

public enum SettingsViewModel {
    public static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    public enum ViewAction {
        #if DEV_MODE
        case resetAppState
        case pruneHistory(reason: String)
        #endif
    }

    public struct ViewState: Equatable {
        public var lastSaved: String
        public var pruneLog: [PruneEvent]

        public init(lastSaved: String, pruneLog: [PruneEvent]) {
            self.lastSaved = lastSaved
            self.pruneLog = pruneLog
        }

        static let empty: ViewState = ViewState(lastSaved: "---", pruneLog: [])
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        #if DEV_MODE
        case .resetAppState: return .resetAppState
        case .pruneHistory(let reason): return .history(.prune(reason: reason))
        #endif
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(lastSaved: {
            guard let date = appState.meta.lastSaved else { return "---" }
            switch date {
            case .failure(let error): return "Error: \(error)"
            case .success(let date): return DateFormatter.relativeMedium.string(from: date)
            }
        }(), pruneLog: appState.history.pruneLog)
    }
}
