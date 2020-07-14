import Foundation
import UserNotifications

protocol UserNotificationCenterProto {
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    func getNotificationSettingsTestable(completionHandler: @escaping (NotificationSettings) -> Void)
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenterProto {
    func getNotificationSettingsTestable(completionHandler: @escaping (NotificationSettings) -> Void) {
        getNotificationSettings(completionHandler: completionHandler)
    }
}

protocol NotificationSettings {
    var authorizationStatus: UNAuthorizationStatus { get }
}

extension UNNotificationSettings: NotificationSettings {}
