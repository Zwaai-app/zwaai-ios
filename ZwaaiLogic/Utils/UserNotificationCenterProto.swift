import Foundation
import UserNotifications

protocol UserNotificationCenterProto {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
}

extension UNUserNotificationCenter: UserNotificationCenterProto {}
