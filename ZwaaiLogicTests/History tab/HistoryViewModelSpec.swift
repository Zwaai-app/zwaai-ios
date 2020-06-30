import SwiftCheck
import XCTest
import SwiftRex
import CombineRex
import Quick
import Nimble
@testable import ZwaaiLogic

class HistoryViewModelProperties: XCTestCase {
    func testAll() {
        property("transform action") <- {
            return HistoryViewModel.transform(viewAction: .lock) == AppAction.history(.lock)
                ^&&^
                HistoryViewModel.transform(viewAction: .tryUnlock) == AppAction.history(.tryUnlock)
        }

        property("transform state") <- forAll { (appState: AppState) in
            return HistoryViewModel.transform(appState: appState)
                == HistoryViewModel.ViewState(
                    entries: appState.history.entries,
                    lock: appState.history.lock,
                    personCount: appState.history.allTimePersonZwaaiCount,
                    spaceCount: appState.history.allTimeSpaceZwaaiCount)
        }
    }
}

class HistoryViewModelSpec: QuickSpec {
    override func spec() {
        it("constructs a view model") {
            let store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: IdentityMiddleware()
            )
            let viewModel = HistoryViewModel.viewModel(from: store)
            expect(viewModel.state) == .empty
            store.dispatch(AppAction.history(.tryUnlock))
            expect(viewModel.state.lock) == .unlocking
        }
    }
}
