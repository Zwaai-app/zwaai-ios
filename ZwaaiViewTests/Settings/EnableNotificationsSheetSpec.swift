import Quick
import Nimble
import SwiftUI
import ViewInspector
@testable import ZwaaiView
import ZwaaiLogic
import UserNotifications

extension EnableNotificationsSheet: Inspectable {}

class EnableNotificationsSheetSpec: QuickSpec {
    @Binding var isPresented: Bool = true
    @Binding var systemPermissions: UNAuthorizationStatus = .notDetermined

    override func spec() {
        var view: EnableNotificationsSheet!
        var onAllowCalled = false
        var onDenyCalled = false

        beforeEach {
            self.isPresented = true
            self.systemPermissions = .notDetermined
            onAllowCalled = false
            onDenyCalled = false
            view = EnableNotificationsSheet(onAllowNotifications: { onAllowCalled = true },
                                            onDenyNotifications: { onDenyCalled = true },
                                            isPresented: self.$isPresented,
                                            systemPermissions: self.$systemPermissions)
        }

        describe("accept") {
            it("has an accept button") {
                let exp = view.inspection.inspect { view in
                    expect(try view.vStack().group(0).hStack(3).button(1).text().string()) == "Akkoord"
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp], timeout: 0.1)
            }

            it("pressing that button requests notifications from system") {
                var didRequest = false
                view.requestPermissionsFromSystem = { _ in didRequest = true }
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).hStack(3).button(1).tap()
                    expect(didRequest) == true
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp], timeout: 0.1)
            }

            it("pressing that button immediately dismisses when system already decided") {
                self.systemPermissions = .authorized
                var didRequest = false
                view.requestPermissionsFromSystem = { _ in didRequest = true }
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).hStack(3).button(1).tap()
                }
                let exp2 = view.inspection.inspect(after: 0.2) { view in
                    expect(try view.actualView().isPresented).to(beFalse())
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp, exp2], timeout: 0.4)
                expect(didRequest).toEventually(beFalse())
            }

            it("calls onAllowed") {
                view.requestPermissionsFromSystem = { completionHandler in
                    completionHandler(true, nil)
                }
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).hStack(3).button(1).tap()
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp], timeout: 0.1)
                expect(onAllowCalled).toEventually(beTrue())
            }

            it("dismisses after permissions were requested from system") {
                view.requestPermissionsFromSystem = { completionHandler in
                    completionHandler(true, nil)
                }
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).hStack(3).button(1).tap()
                }
                let exp2 = view.inspection.inspect(after: 0.2) { view in
                    expect(try view.actualView().isPresented).to(beFalse())
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp, exp2], timeout: 10)
            }
        }

        describe("deny") {
            it("has a deny button") {
                let exp = view.inspection.inspect { view in
                    expect(try view.vStack().group(0).hStack(3).button(3).text().string()) == "Niet akkoord"
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp], timeout: 0.1)
            }

            it("pressing that button calls onDenyNotifications") {
                var didRequest = false
                view.requestPermissionsFromSystem = { _ in didRequest = true }
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).hStack(3).button(3).tap()
                    expect(didRequest) == false
                }
                let exp1 = view.inspection.inspect(after: 0.2) { view in
                    expect(try view.actualView().isPresented) == false
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp, exp1], timeout: 0.5)
                expect(onDenyCalled).toEventually(beTrue())
            }
        }

        describe("decide later") {
            it("has a decide later button") {
                let exp = view.inspection.inspect { view in
                    expect(try view.vStack().group(0).button(4).text().string()) == "Later beslissen"
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp], timeout: 0.1)
            }

            it("tapping that button dismisses the sheet") {
                let exp = view.inspection.inspect { view in
                    try view.vStack().group(0).button(4).tap()
                }
                let exp1 = view.inspection.inspect(after: 0.2) { view in
                    expect(try view.actualView().isPresented) == false
                }
                ViewHosting.host(view: view)
                QuickSpec.current.wait(for: [exp, exp1], timeout: 0.5)
                expect(onAllowCalled).toEventually(beFalse())
                expect(onDenyCalled).toEventually(beFalse())
            }
        }
    }
}
