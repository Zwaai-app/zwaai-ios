import XCTest
import SwiftCheck
import SwiftRex
import CombineRex
import Quick
import Nimble
@testable import ZwaaiLogic

class ZwaaiViewModelProperties: XCTestCase {
    func testAll() {
        property("translates actions") <- forAll { (space: CheckedInSpace) in
            return ZwaaiViewModel.transform(viewAction: .checkout(space: space))
                == AppAction.zwaai(.checkout(space: space))
        }

        property("translates state") <- forAll { (appState: AppState) in
            return ZwaaiViewModel.transform(appState: appState)
                == ZwaaiViewModel.ViewState(checkedIn: appState.zwaai.checkedIn)
        }
    }
}

class ZwaaiViewModelSpec: QuickSpec {
    override func spec() {
        it("constructs a view model") {
            let store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: IdentityMiddleware()
            )
            let viewModel = ZwaaiViewModel.viewModel(from: store)
            expect(viewModel.state) == .empty
            let space = CheckedInSpace(name: "test", description: "test", autoCheckout: nil)
            store.dispatch(AppAction.zwaai(.checkin(space: space)))
            expect(viewModel.state.checkedIn) == space
        }
    }
}
