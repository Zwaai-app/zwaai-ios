import Quick
import Nimble
@testable import ZwaaiLogic
import UIKit

class AppMetaActionsSpec: QuickSpec {
    override func spec() {
        describe("equality") {
            it("equates didSaveState") {
                let now = Date()
                expect(AppMetaAction.didSaveState(result: .success(now)))
                    == .didSaveState(result: .success(now))
                expect(AppMetaAction.didSaveState(result: .success(now)))
                    != .didSaveState(result: .failure(.noUserDocumentsDirectory))
                expect(AppMetaAction.didSaveState(result: .success(now)))
                    != .setupAutoCheckout
            }

            it("equates zwaaiSucceeded") {
                let controller1 = UIViewController()
                let controller2 = UIViewController()
                let onDismiss1 = { _ = 1 }
                let onDismiss2 = { _ = 2 }

                expect(AppMetaAction.zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1))
                    == .zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1)
                expect(AppMetaAction.zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1))
                    == .zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss2)
                expect(AppMetaAction.zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1))
                    != .zwaaiSucceeded(presentingController: controller2, onDismiss: onDismiss1)
                expect(AppMetaAction.zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1))
                    != .zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1)
            }

            it("equates zwaaiFailed") {
                let controller1 = UIViewController()
                let controller2 = UIViewController()
                let onDismiss1 = { _ = 1 }
                let onDismiss2 = { _ = 2 }

                expect(AppMetaAction.zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1))
                    == .zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1)
                expect(AppMetaAction.zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1))
                    == .zwaaiFailed(presentingController: controller1, onDismiss: onDismiss2)
                expect(AppMetaAction.zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1))
                    != .zwaaiFailed(presentingController: controller2, onDismiss: onDismiss1)
                expect(AppMetaAction.zwaaiFailed(presentingController: controller1, onDismiss: onDismiss1))
                    != .zwaaiSucceeded(presentingController: controller1, onDismiss: onDismiss1)
            }

            it("equates setupAutoCheckout") {
                expect(AppMetaAction.setupAutoCheckout) == .setupAutoCheckout
                expect(AppMetaAction.setupAutoCheckout) != .didSaveState(result: .success(Date()))
            }

            it("equates checkSystemNotificationPermissions") {
                expect(AppMetaAction.checkSystemNotificationPermissions) == .checkSystemNotificationPermissions
                expect(AppMetaAction.checkSystemNotificationPermissions) != .setupAutoCheckout
            }

            it("equates set(systemNotificationPermission:)") {
                let actions: [AppMetaAction] = [
                    .set(systemNotificationPermission: .notDetermined),
                    .set(systemNotificationPermission: .authorized),
                    .set(systemNotificationPermission: .denied),
                    .set(systemNotificationPermission: .provisional),
                    .setupAutoCheckout
                ]

                for actionIndex in 0 ..< actions.count {
                    var otherActions = actions
                    let action = otherActions.remove(at: actionIndex)

                    expect(action) == action
                    for otherAction in otherActions {
                        expect(action) != otherAction
                    }
                }
            }
        }
    }
}
