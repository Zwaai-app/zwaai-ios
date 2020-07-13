import Quick
import Nimble
import SwiftUI
import CombineRex
import ViewInspector
@testable import ZwaaiView
import ZwaaiLogic
import UserNotifications

extension SettingsTab: Inspectable {}

class SettingsTabSpec: QuickSpec {
    override func spec() {
        var viewModel: ObservableViewModel<SettingsViewModel.ViewAction, SettingsViewModel.ViewState>!
        var view: SettingsTab!

        it("has a button to enable notifications if permission undecided") {
            viewModel = mockViewModel(.undecided, .notDetermined)
            view = SettingsTab(viewModel: viewModel)
            let exp = view.inspection.inspect { view in
                let button = try view.list().section(0).button(0)
                expect(try button.text().string()) == "Sta berichtgeving toe"
                try button.tap()
                expect(try view.actualView().showEnableNotifications) == true
            }
            ViewHosting.host(view: view)
            QuickSpec.current.wait(for: [exp], timeout: 0.1)
        }

        it("has a toggle set to off if denied") {
            viewModel = mockViewModel(.denied, .denied)
            view = SettingsTab(viewModel: viewModel)
            let exp = view.inspection.inspect { view in
                expect(try view.list().section(0).toggle(0).text().string()) == "Voor automatisch uitchecken"
                expect(try view.actualView().appNotificationPermissionAsBinding().wrappedValue) == false
            }
            ViewHosting.host(view: view)
            QuickSpec.current.wait(for: [exp], timeout: 0.1)
        }

        it("has a toggle set to on if allowed") {
            viewModel = mockViewModel(.allowed, .authorized)
            view = SettingsTab(viewModel: viewModel)
            let exp = view.inspection.inspect { view in
                expect(try view.list().section(0).toggle(0).text().string()) == "Voor automatisch uitchecken"
                expect(try view.actualView().appNotificationPermissionAsBinding().wrappedValue) == true
            }
            ViewHosting.host(view: view)
            QuickSpec.current.wait(for: [exp], timeout: 0.1)
        }

        it("has a button to enable notifications if permissions conclict") {
            viewModel = mockViewModel(.allowed, .denied)
            view = SettingsTab(viewModel: viewModel)
            let exp = view.inspection.inspect { view in
                let button = try view.list().section(0).button(0)
                expect(try button.hStack().text(1).string()) == "Sta berichtgeving toe"
                expect(try button.hStack().text(1).accessibilityLabel().string())
                    == "Let op: sta berichtgeving toe"
            }
            ViewHosting.host(view: view)
            QuickSpec.current.wait(for: [exp], timeout: 0.1)
        }
    }
}

func mockViewModel(
    _ appNotificationPermission: NotificationPermission,
    _ systemNotificationPermissions: UNAuthorizationStatus
) -> ObservableViewModel<SettingsViewModel.ViewAction, SettingsViewModel.ViewState> {
    return .mock(
        state: SettingsViewModel.ViewState(
            lastSaved: "",
            pruneLog: [],
            appNotificationPermission: appNotificationPermission,
            systemNotificationPermissions: systemNotificationPermissions),
        action: { _, _, _ in })
}
