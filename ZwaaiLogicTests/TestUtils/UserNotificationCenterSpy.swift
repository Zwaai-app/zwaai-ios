import Foundation
import UserNotifications
@testable import ZwaaiLogic

class UserNotificationCenterSpy: UserNotificationCenterProto {
    var requestedAuthorizations = [UNAuthorizationOptions]()
    var addRequests = [UNNotificationRequest]()

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestedAuthorizations.append(options)
        completionHandler(true, nil)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addRequests.append(request)
        completionHandler?(nil)
    }
}
