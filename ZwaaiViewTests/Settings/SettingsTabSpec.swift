import Quick
import Nimble
import SwiftUI
import CombineRex
import ViewInspector
@testable import ZwaaiView
import ZwaaiLogic

extension SettingsTab: Inspectable {}

class SettingsTabSpec: QuickSpec {
    override func spec() {
        var viewModel: ObservableViewModel<SettingsViewModel.ViewAction, SettingsViewModel.ViewState>!
        var view: SettingsTab!

        it("has a button to enable notifications") {
            viewModel = .mock(state: SettingsViewModel.ViewState.empty,
                              action: { _, _, _ in })
            view = SettingsTab(viewModel: viewModel)
            let exp = view.inspection.inspect { view in
                expect(try view.list().button(0).text().string()) == "Sta berichtgeving toe"
                try view.list().button(0).tap()
            }
            ViewHosting.host(view: view)
            QuickSpec.current.wait(for: [exp], timeout: 0.1)
        }
    }
}
