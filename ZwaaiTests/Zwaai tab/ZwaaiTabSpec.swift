import Quick
import Nimble
import SwiftUI
import CombineRex
import ViewInspector
@testable import ZwaaiLogic

extension ZwaaiTab: Inspectable {}
extension BigButton: Inspectable {}

class ZwaaiTabSpec: QuickSpec {
    override func spec() {
        var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>!
        var view: ZwaaiTab!

        context("when not checked in") {
            beforeEach {
                viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
                    state: ZwaaiViewModel.ViewState.empty,
                    action: { _, _, _ in })
                view = ZwaaiTab(viewModel: viewModel)
            }

            it("has a button for zwaai with person") {
                expect(try view.inspect().personButton().buttonText().string()) == "Zwaai met persoon"
            }

            it("has a button for checking in") {
                expect(try view.inspect().roomButton().buttonText().string()) == "Zwaai in ruimte"
            }
        }

        context("when checked in without auto checkout") {
            let testSpace = CheckedInSpace(name: "test", description: "test", autoCheckout: nil)

            beforeEach {
                viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
                    state: ZwaaiViewModel.ViewState(checkedIn: testSpace),
                    action: { _, _, _ in })
                view = ZwaaiTab(viewModel: viewModel)
            }

            it("has a button for zwaai with person") {
                expect(try view.inspect().personButton().buttonText().string()) == "Zwaai met persoon"
            }

            it("has a button for checking out") {
                expect(try view.inspect().roomButton().buttonText().string()) == "Ingecheckt"
            }
        }

        context("when checked in with auto checkout") {
            let testSpace = CheckedInSpace(name: "test", description: "test", autoCheckout: 60)

            beforeEach {
                viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
                    state: ZwaaiViewModel.ViewState(checkedIn: testSpace),
                    action: { _, _, _ in })
                view = ZwaaiTab(viewModel: viewModel)
            }

            it("has a button for zwaai with person") {
                expect(try view.inspect().personButton().buttonText().string()) == "Zwaai met persoon"
            }

            it("has a button for checking out") {
                expect(try view.inspect().roomButton().buttonText().string())
                    == "Ingecheckt tot \(view.formattedDeadline())"
            }
        }
    }
}

extension InspectableView where View == ViewType.View<ZwaaiTab> {
    func personButtonLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try vStack().navigationLink(0)
    }

    func personButton() throws -> InspectableView<ViewType.View<BigButton>> {
        return try personButtonLink().label().view(BigButton.self)
    }

    func roomButtonLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try vStack().navigationLink(1)
    }

    func roomButton() throws -> InspectableView<ViewType.View<BigButton>> {
        return try roomButtonLink().label().view(BigButton.self)
    }
}

extension InspectableView where View == ViewType.View<BigButton> {
    func buttonText() throws -> InspectableView<ViewType.Text> {
        return try vStack().text(1)
    }
}
