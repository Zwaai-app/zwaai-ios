import SwiftCheck
import XCTest
import Quick
import Nimble
import SwiftRex
import Combine
@testable import ZwaaiLogic

class SettingsViewModelProperties: XCTestCase {
    func testAll() {
        property("transforms actions") <- {
            return SettingsViewModel.transform(viewAction: .resetAppState)
                    == .resetAppState
                ^&&^
                SettingsViewModel.transform(viewAction: .allowNotifications)
                    == .settings(.set(notificationPermission: .allowed))
                ^&&^
                SettingsViewModel.transform(viewAction: .denyNotifications)
                    == .settings(.set(notificationPermission: .denied))
        }

        property("transforms state") <- forAll { (appState: AppState) in
            let viewState = SettingsViewModel.transform(appState: appState)

            if let lastSaved = appState.meta.lastSaved {
                switch lastSaved {
                case .failure:
                    return viewState.lastSaved.starts(with: "Error:")
                case .success(let date):
                    let formattedDate = DateFormatter.relativeMedium.string(from: date)
                    return viewState == SettingsViewModel.ViewState(
                        lastSaved: formattedDate,
                        pruneLog: appState.history.pruneLog,
                        appNotificationPermission: appState.settings.notificationPermission,
                        systemNotificationPermissions: appState.meta.systemNotificationPermission ?? .notDetermined)
                }
            } else {
                return viewState == SettingsViewModel.ViewState(
                    lastSaved: "---",
                    pruneLog: appState.history.pruneLog,
                    appNotificationPermission: appState.settings.notificationPermission,
                    systemNotificationPermissions: appState.meta.systemNotificationPermission ?? .notDetermined)
            }
        }
    }
}

class SettingsViewModelSpec: QuickSpec {
    override func spec() {
        it("constructs a view model") {
            let store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: IdentityMiddleware()
            )
            let viewModel = SettingsViewModel.viewModel(from: store)
            expect(viewModel.state) == .empty
            let date = Date()
            store.dispatch(AppAction.meta(.didSaveState(result: .success(date))))
            expect(viewModel.state.lastSaved) == DateFormatter.relativeMedium.string(from: date)
        }
    }
}
