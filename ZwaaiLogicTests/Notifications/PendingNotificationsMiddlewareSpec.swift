import Quick
import Nimble
import SwiftRex
import Combine
@testable import ZwaaiLogic
import UserNotifications

class PendingNotificationsMiddlewareSpec: QuickSpec {
    override func spec() {
        var notificationsSpy: UserNotificationCenterSpy!
        var testDeps: UserNotificationDeps!
        var pendingNotificationsMiddleware: PendingNotificationsMiddleware!
        var store: ReduxStoreBase<AppAction, AppState>!
        var cancellable: AnyCancellable!
        var receivedState: AppState?

        beforeEach {
            receivedState = nil
            notificationsSpy = UserNotificationCenterSpy()
            testDeps = UserNotificationDeps(
                fileManager: FileManager.default,
                userNotificationCenter: notificationsSpy
            )
            pendingNotificationsMiddleware = PendingNotificationsMiddleware()
            pendingNotificationsMiddleware.deps = testDeps
            let middleware: AnyMiddleware<AppAction, AppAction, AppState>
                = pendingNotificationsMiddleware.lift(
                    outputActionMap: { action in return .meta(.notification(action: action)) },
                    stateMap: ignore
                ).eraseToAnyMiddleware()
            store = ReduxStoreBase(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: middleware
            )
            cancellable = store.statePublisher.sink(receiveValue: { appState in
                receivedState = appState
            })
        }

        afterEach {
            cancellable.cancel()
        }

        it("gets notifications from system") {
            store.dispatch(.meta(.notification(action: .getPending)))
            expect(notificationsSpy.getPendingNotificationRequestsCount).toEventually(equal(1))
        }

        it("only gets notifications from system on correct action") {
            store.dispatch(.meta(.notification(action: .checkSystemPermissions)))
            expect(notificationsSpy.getPendingNotificationRequestsCount).toEventually(equal(0))
        }

        it("stores empty list if nothing pending") {
            let request = createFakeNotificationRequest()
            store.dispatch(.meta(.notification(action: .setPending(requests: [request]))))
            expect(receivedState?.meta.pendingNotifications) == [UUID(uuidString: request.identifier)!]

            store.dispatch(.meta(.notification(action: .getPending)))
            expect(receivedState?.meta.pendingNotifications).toEventually(equal([]))
        }

        it("stores pending UUIDs") {
            let request = createFakeNotificationRequest()
            let uuid = UUID(uuidString: request.identifier)!
            notificationsSpy.pendingRequests = [request]

            store.dispatch(.meta(.notification(action: .getPending)))
            expect(receivedState?.meta.pendingNotifications).toEventually(equal([uuid]))
        }

        it("can remove a pending notification") {
            let req1 = createFakeNotificationRequest()
            let uuid1 = UUID(uuidString: req1.identifier)!
            let req2 = createFakeNotificationRequest()
            let uuid2 = UUID(uuidString: req2.identifier)!

            store.dispatch(.meta(.notification(action: .setPending(requests: [req1, req2]))))

            store.dispatch(.meta(.notification(action: .removePending(requestId: uuid2))))
            expect(notificationsSpy.removePendingNotificationRequestsCount).toEventually(equal(1))
            expect(receivedState?.meta.pendingNotifications).toEventually(equal([uuid1]))
        }

        it("removes pending notification when space is checked out") {
            let space = testSpace(autoCheckout: 1800)
            let request = UNNotificationRequest(
                identifier: space.id.uuidString,
                content: UNNotificationContent(),
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1800, repeats: false))
            store.dispatch(.meta(.notification(action: .setPending(requests: [request]))))
            expect(receivedState?.meta.pendingNotifications) == [space.id]
            notificationsSpy.pendingRequests = [request]

            store.dispatch(.zwaai(.checkout(space: space)))
            expect(receivedState?.meta.pendingNotifications).toEventually(equal([]))
            expect(notificationsSpy.pendingRequests) == []
        }
    }
}
