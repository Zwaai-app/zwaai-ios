import Quick
import Nimble
import SwiftCheck
@testable import ZwaaiLogic
import UIKit
import UserNotifications

class AppMetaReducerSpec: QuickSpec {
    override func spec() {
        it("reduces didSaveState(result:)") {
            let action = AppMetaAction.didSaveState(result: .success(Date()))
            let newState = appMetaReducer.reduce(action, initialMetaState)
            expect(newState.lastSaved) == action.didSaveState
        }

        it("reduces set(systemPermission:)") {
            let action = AppMetaAction.notification(action: .set(systemPermission: .authorized))
            let newState = appMetaReducer.reduce(action, initialMetaState)
            expect(newState.systemNotificationPermission) == .authorized
        }

        it("stores feedback continuation info") {
            let space = testSpace()
            let url = ZwaaiURL(type: .space(space: space))
            let ctrl = UIViewController()
            var dismissed = false
            let onDismiss = { dismissed = true }
            let continuation = FeedbackContinuation(url: url, presentingController: ctrl, onDismiss: onDismiss)
            let action = AppMetaAction.setFeedbackContinuation(continuation: continuation)
            let newState = appMetaReducer.reduce(action, initialMetaState)
            expect(newState.feedbackContinuation) == continuation
            newState.feedbackContinuation?.onDismiss()
            expect(dismissed).to(beTrue())
        }

        it("clears feedback continuation info") {
            let space = testSpace()
            let url = ZwaaiURL(type: .space(space: space))
            let ctrl = UIViewController()
            let onDismiss = {}
            let continuation = FeedbackContinuation(url: url, presentingController: ctrl, onDismiss: onDismiss)
            let action = AppMetaAction.clearFeedbackContinuation
            var state = initialMetaState
            state.feedbackContinuation = continuation
            let newState = appMetaReducer.reduce(action, state)
            expect(newState.feedbackContinuation).to(beNil())
        }

        describe("middleware-only actions") {
            let url = ZwaaiURL(type: .person(random: Random()))
            let ctrl = UIViewController()

            itBehavesLike(IdentityAction.self) { .zwaaiSucceeded(url: url, presentingController: ctrl, onDismiss: {}) }
            itBehavesLike(IdentityAction.self) { .zwaaiFailed(presentingController: ctrl, onDismiss: {}) }
            itBehavesLike(IdentityAction.self) { .setupAutoCheckout }
            itBehavesLike(IdentityAction.self) { .notification(action: .checkSystemPermissions) }
            itBehavesLike(IdentityAction.self) { .notification(action: .getPending) }
        }
    }
}

private class IdentityAction: Behavior<AppMetaAction> {
    override class func spec(_ context: @escaping () -> AppMetaAction) {
        it("does not change the state") {
            let action = context()
            let state = appMetaReducer.reduce(action, initialMetaState)
            expect(state) == initialMetaState
        }
    }
}

class NotificationReducerSpec: QuickSpec {
    override func spec() {
        it("does not change state on getPending") {
            let pending = [UUID(), UUID()]
            let state = AppMetaState(lastSaved: nil,
                                     systemNotificationPermission: nil,
                                     pendingNotifications: pending)
            let newState = notificationReducer.reduce(.getPending, state)
            expect(newState.pendingNotifications) == pending
        }

        it("replaces uuids on setPending") {
            let pendingBefore = [UUID(), UUID()]
            let newNotification1 = createFakeNotificationRequest()
            let newNotification2 = createFakeNotificationRequest()
            let state = AppMetaState(lastSaved: nil,
                                     systemNotificationPermission: nil,
                                     pendingNotifications: pendingBefore)
            let action = NotificationAction.setPending(requests: [newNotification1, newNotification2])
            let newState = notificationReducer.reduce(action, state)
            expect(newState.pendingNotifications) == [
                UUID(uuidString: newNotification1.identifier),
                UUID(uuidString: newNotification2.identifier)
            ]
        }

        it("can remove a specific pending notification") {
            let uuid = UUID()
            let uuidToRemove = UUID()
            let state = AppMetaState(lastSaved: nil,
                                     systemNotificationPermission: nil,
                                     pendingNotifications: [uuid, uuidToRemove])
            let newState = notificationReducer.reduce(.removePending(requestId: uuidToRemove), state)
            expect(newState.pendingNotifications) == [uuid]
        }
    }
}

let createFakeNotificationRequest = { UNNotificationRequest(
    identifier: UUID().uuidString,
    content: UNNotificationContent(),
    trigger: UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false))
}
