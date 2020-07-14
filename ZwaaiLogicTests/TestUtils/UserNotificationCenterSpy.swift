import Foundation
import UserNotifications
@testable import ZwaaiLogic

class UserNotificationCenterSpy: UserNotificationCenterProto {
    var requestedAuthorizations = [UNAuthorizationOptions]()
    var pendingRequests = [UNNotificationRequest]()
    var fakeNotificationSettings: NotificationSettings
        = NotificationSettingsDummy(authorizationStatus: .notDetermined)
    var getNotificationSettingsCount = 0
    var getPendingNotificationRequestsCount = 0
    var removePendingNotificationRequestsCount = 0

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestedAuthorizations.append(options)
        completionHandler(true, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        pendingRequests.append(request)
        completionHandler?(nil)
    }

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        getPendingNotificationRequestsCount += 1
        DispatchQueue.main.async {
            completionHandler(self.pendingRequests)
        }
    }

    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        fatalError("please use getNotificationSettingsTestable for testability reasons")
    }

    func getNotificationSettingsTestable(completionHandler: @escaping (NotificationSettings) -> Void) {
        getNotificationSettingsCount += 1
        DispatchQueue.main.async {
            completionHandler(self.fakeNotificationSettings)
        }
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
        removePendingNotificationRequestsCount += 1
    }
}

class NotificationSettingsDummy: NotificationSettings {
    var authorizationStatus: UNAuthorizationStatus

    init(authorizationStatus: UNAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
    }
}
