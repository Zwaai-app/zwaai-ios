import Quick
import Nimble
import SwiftRex
import Combine
@testable import ZwaaiLogic

class CheckSystemNotificationPermissionsMiddlewareSpec: QuickSpec {
    override func spec() {
        var notificationsSpy: UserNotificationCenterSpy!
        var testDeps: UserNotificationDeps!
        var checkNotificationsMiddleware: CheckSystemNotificationPermissionsMiddleware!
        var store: ReduxStoreBase<AppAction, AppState>!

        beforeEach {
            notificationsSpy = UserNotificationCenterSpy()
            testDeps = UserNotificationDeps(
                fileManager: FileManager.default,
                userNotificationCenter: notificationsSpy)
            checkNotificationsMiddleware = CheckSystemNotificationPermissionsMiddleware()
            checkNotificationsMiddleware.deps = testDeps
            let middleware: AnyMiddleware<AppAction, AppAction, AppState>
                = checkNotificationsMiddleware.lift(
                    inputActionMap: \AppAction.meta,
                    outputActionMap: AppAction.meta,
                    stateMap: ignore
                ).eraseToAnyMiddleware()
            store = ReduxStoreBase(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: middleware)
        }

        it("gets permissions from system") {
            store.dispatch(.meta(.checkSystemNotificationPermissions))
            expect(notificationsSpy.getNotificationSettingsCount).toEventually(equal(1))
        }

        describe("dispatches the right action on") {
            var cancellable: AnyCancellable!
            var receivedState: AppState?

            beforeEach {
                receivedState = nil
                cancellable = store.statePublisher.sink { appState in
                    receivedState = appState
                }
            }

            afterEach {
                cancellable.cancel()
            }

            it("dispatches right action on notDetermined") {
                notificationsSpy.fakeNotificationSettings
                    = NotificationSettingsDummy(authorizationStatus: .notDetermined)
                store.dispatch(.meta(.checkSystemNotificationPermissions))
                expect(receivedState?.meta.systemNotificationPermission).toEventually(equal(.notDetermined))
            }

            it("dispatches right action on authorized") {
                notificationsSpy.fakeNotificationSettings
                    = NotificationSettingsDummy(authorizationStatus: .authorized)
                store.dispatch(.meta(.checkSystemNotificationPermissions))
                expect(receivedState?.meta.systemNotificationPermission).toEventually(equal(.authorized))
            }

            it("dispatches right action on denied") {
                notificationsSpy.fakeNotificationSettings
                    = NotificationSettingsDummy(authorizationStatus: .denied)
                store.dispatch(.meta(.checkSystemNotificationPermissions))
                expect(receivedState?.meta.systemNotificationPermission).toEventually(equal(.denied))
            }

            it("dispatches right action on provisional") {
                notificationsSpy.fakeNotificationSettings
                    = NotificationSettingsDummy(authorizationStatus: .provisional)
                store.dispatch(.meta(.checkSystemNotificationPermissions))
                expect(receivedState?.meta.systemNotificationPermission).toEventually(equal(.provisional))
            }
        }
    }
}
