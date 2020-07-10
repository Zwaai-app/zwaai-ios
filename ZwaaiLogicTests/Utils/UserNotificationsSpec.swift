import Quick
import Nimble
@testable import ZwaaiLogic
import UserNotifications

class UserNotificationsSpec: QuickSpec {
    override func spec() {
        var fileManagerSpy: FileManagerSpy!
        var userNotificationCenterSpy: UserNotificationCenterSpy!
        var deps: UserNotificationDeps!

        beforeEach {
            fileManagerSpy = FileManagerSpy(
                fileExists: true,
                urls: [.libraryDirectory: URL(string: "file:///tmp/Library")!])
            userNotificationCenterSpy = UserNotificationCenterSpy()
            deps = UserNotificationDeps(fileManager: fileManagerSpy,
                                        userNotificationCenter: userNotificationCenterSpy)
        }

        describe("scheduling") {
            beforeEach {
                notificationSound = UNNotificationSound.default
            }

            afterEach {
                notificationSound = nil
            }

            it("doesn't schedule without deadline") {
                let space = CheckedInSpace(name: "test", description: "test", autoCheckout: nil)
                scheduleLocalNotification(space: space, deps: deps)
                expect(userNotificationCenterSpy.pendingRequests).toEventually(haveCount(0))
            }

            it("schedules the right notification") {
                let space = CheckedInSpace(
                    name: "Test name",
                    description: "test desc",
                    autoCheckout: 1800,
                    deadline: Date(timeIntervalSinceNow: 300))
                scheduleLocalNotification(space: space, deps: deps)
                expect(userNotificationCenterSpy.pendingRequests).toEventually(haveCount(1))
                let addedNotification = userNotificationCenterSpy.pendingRequests[0]

                expect(addedNotification.identifier) == space.id.uuidString

                let content = addedNotification.content
                expect(content.title).to(contain("Ruimte is automatisch verlaten"))
                expect(content.body).to(contain(space.name))
                expect(content.sound) == .default

                let trigger = addedNotification.trigger!
                    as! UNTimeIntervalNotificationTrigger // swiftlint:disable:this force_cast
                expect(trigger.repeats).to(beFalse())
                expect(trigger.nextTriggerDate()?.timeIntervalSince(space.deadline!)) ≈ 0 ± 0.01
            }

            it("doesn't schedule twice for one space") {
                let space = CheckedInSpace(
                    name: "Test name",
                    description: "test desc",
                    autoCheckout: 1800,
                    deadline: Date(timeIntervalSinceNow: 300))
                scheduleLocalNotification(space: space, deps: deps)
                expect(userNotificationCenterSpy.pendingRequests).toEventually(haveCount(1))
                scheduleLocalNotification(space: space, deps: deps)
                expect(userNotificationCenterSpy.pendingRequests).toEventually(haveCount(1))
            }
        }

        describe("request permission") {
            it("requests the right permissions") {
                requestLocalNotificationPermission(deps: deps) { _, _ in }
                expect(userNotificationCenterSpy.requestedAuthorizations).to(haveCount(1))
                let requestedAuth = userNotificationCenterSpy.requestedAuthorizations[0]
                expect(requestedAuth) == [.sound, .alert]
            }

            it("copies the audio file to the right location") {
                requestLocalNotificationPermission(deps: deps) { _, _ in }
                expect(fileManagerSpy.createdDirectories).to(haveCount(1))
                let (dir, intermediates, _) = fileManagerSpy.createdDirectories[0]
                expect(dir.pathComponents[dir.pathComponents.count-2]) == "Library"
                expect(dir.pathComponents[dir.pathComponents.count-1]) == "Sounds"
                expect(intermediates).to(beTrue())

                expect(fileManagerSpy.copiedItems).to(haveCount(1))
                let (source, destination) = fileManagerSpy.copiedItems[0]
                expect(source.absoluteString).to(endWith(".wav"))
                expect(destination.absoluteString)
                    == dir.appendingPathComponent(source.lastPathComponent).absoluteString
            }

            it("doesn't have a sound when something not found") {
                fileManagerSpy.urls = [:]
                requestLocalNotificationPermission(deps: deps) { _, _ in }
                expect(notificationSound).to(beNil())
            }

            it("doesn't have a sound when copy fails") {
                fileManagerSpy.createShouldThrow = TestError.testError
                requestLocalNotificationPermission(deps: deps) { _, _ in }
                expect(notificationSound).to(beNil())
            }
        }
    }
}
