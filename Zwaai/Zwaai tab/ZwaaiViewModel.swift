import SwiftRex
import CombineRex

enum ZwaaiViewModel {
    static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    enum ViewAction {
        case checkout
    }

    struct ViewState: Equatable {
        var checkedIn: Space?

        static let empty: ViewState = ViewState()
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .checkout: return .zwaai(.checkout)
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(checkedIn: appState.zwaai.checkedIn)
    }
}
