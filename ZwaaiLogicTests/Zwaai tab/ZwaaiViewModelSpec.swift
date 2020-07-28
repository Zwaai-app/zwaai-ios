import XCTest
import SwiftCheck
import SwiftRex
import CombineRex
import Quick
import Nimble
@testable import ZwaaiLogic

class ZwaaiViewModelProperties: XCTestCase {
    func testAll() {
        property("transforms actions") <- forAll { (space: CheckedInSpace) in
            let transform: (ZwaaiViewModel.ViewAction) -> AppAction? = { action in
                return ZwaaiViewModel.transform(viewAction: action)
            }
            return transform(.checkout(space: space)) == AppAction.zwaai(.checkout(space: space))
                && transform(.allowNotifications) == AppAction.settings(.set(notificationPermission: .allowed))
                && transform(.denyNotifications) == AppAction.settings(.set(notificationPermission: .denied))
        }

        property("transforms state") <- forAll { (appState: AppState) in
            return ZwaaiViewModel.transform(appState: appState)
                == ZwaaiViewModel.ViewState(
                    checkedIn: appState.zwaai.checkedIn,
                    notificationPermission: appState.settings.notificationPermission,
                    systemNotificationPermissions: appState.meta.systemNotificationPermission ?? .notDetermined)
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
            let space = testSpace()
            store.dispatch(AppAction.zwaai(.checkin(space: space)))
            expect(viewModel.state.checkedIn) == space
        }
    }
}
