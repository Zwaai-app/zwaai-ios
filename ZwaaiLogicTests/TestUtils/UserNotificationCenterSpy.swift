import Foundation
import UserNotifications
@testable import ZwaaiLogic

class UserNotificationCenterSpy: UserNotificationCenterProto {
    var requestedAuthorizations = [UNAuthorizationOptions]()
    var pendingRequests = [UNNotificationRequest]()

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestedAuthorizations.append(options)
        completionHandler(true, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        pendingRequests.append(request)
        completionHandler?(nil)
    }

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        DispatchQueue.main.async {
            completionHandler(self.pendingRequests)
        }
    }
}
