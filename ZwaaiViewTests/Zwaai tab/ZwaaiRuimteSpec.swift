import Quick
import Nimble
import SwiftUI
import CombineRex
import ViewInspector
import ZwaaiLogic
@testable import ZwaaiView

extension ZwaaiRuimte: Inspectable {}
extension ZwaaiRuimteCheckedIn: Inspectable {}
extension ZwaaiRuimteCheckedOut: Inspectable {}

class ZwaaiRuimteSpec: QuickSpec {
    override func spec() {
        var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>!
        var view: ZwaaiRuimte!

        context("when not checked in") {
            beforeEach {
                viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
                    state: ZwaaiViewModel.ViewState.empty,
                    action: { _, _, _ in })
                view = ZwaaiRuimte(viewModel: viewModel)
            }

            it("shows scanner") {
                let checkedOut = try view.inspect().zwaaiRuimteCheckedOut()
                expect(try checkedOut.vStack().text(1).string())
                    .to(contain("Scan de QR code"))
            }
        }

        context("when checked in") {
            let testSpace = CheckedInSpace(name: "test", locationCode: GroupElement.random(),
                                           description: "testDesc", autoCheckout: 60,
                                           locationTimeCodes: [])
            var recordedActions: [ZwaaiViewModel.ViewAction]!

            beforeEach {
                recordedActions = []
                viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
                    state: ZwaaiViewModel.ViewState(checkedInStatus: .succeeded(value: testSpace),
                                                    notificationPermission: .undecided,
                                                    systemNotificationPermissions: .notDetermined),
                    action: { action, _, _ in recordedActions.append(action) })
                view = ZwaaiRuimte(viewModel: viewModel)
            }

            it("shows details about checked-in space") {
                let checkedIn = try view.inspect().zwaaiRuimteCheckedIn()
                expect(try checkedIn.vStack().text(1).string()) == "Ingecheckt bij:"
                expect(try checkedIn.vStack().vStack(3).text(0).string()) == testSpace.name
                expect(try checkedIn.vStack().vStack(3).text(1).string()) == testSpace.desc
            }

            it("shows checkout button") {
                let checkedIn = try view.inspect().zwaaiRuimteCheckedIn()
                expect(try checkedIn.vStack().button(5).vStack().text(1).string()) == "Nu verlaten"
            }

            it("clicking checkout dispatches checkout") {
                let checkedIn = try view.inspect().zwaaiRuimteCheckedIn()
                try checkedIn.vStack().button(5).tap()
                expect(recordedActions).to(haveCount(1))
                expect(recordedActions) == [.checkout(space: testSpace)]
            }
        }
    }
}

extension InspectableView where View == ViewType.View<ZwaaiRuimte> {
    func zwaaiRuimteCheckedIn() throws -> InspectableView<ViewType.View<ZwaaiRuimteCheckedIn>> {
        return try anyView().view(ZwaaiRuimteCheckedIn.self)
    }

    func zwaaiRuimteCheckedOut() throws -> InspectableView<ViewType.View<ZwaaiRuimteCheckedOut>> {
        return try anyView().view(ZwaaiRuimteCheckedOut.self)
    }
}
