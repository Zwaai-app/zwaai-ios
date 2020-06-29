import SwiftRex
import CombineRex

public enum ZwaaiViewModel {
    public static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    public enum ViewAction {
        case checkout(space: CheckedInSpace)
    }

    public struct ViewState: Equatable {
        public var checkedIn: CheckedInSpace?

        public init(checkedIn: CheckedInSpace? = nil) {
            self.checkedIn = checkedIn
        }

        public static let empty: ViewState = ViewState()
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .checkout(let space): return .zwaai(.checkout(space: space))
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(checkedIn: appState.zwaai.checkedIn)
    }
}
