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
        #if DEBUG
        case resetAppState
        #endif
    }

    public struct ViewState: Equatable {
        public var lastSaved: String

        public init(lastSaved: String) {
            self.lastSaved = lastSaved
        }

        static let empty: ViewState = ViewState(lastSaved: "---")
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        #if DEBUG
        case .resetAppState: return .resetAppState
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
        }())
    }
}
