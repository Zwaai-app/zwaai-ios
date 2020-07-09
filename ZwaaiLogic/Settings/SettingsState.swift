import Foundation

public struct SettingsState: Equatable, Codable, CustomStringConvertible {
    public var notificationPermission: NotificationPermission

    public var description: String {
        return "{notificationPermission: \(notificationPermission)}"
    }
}

public let initialSettingsState = SettingsState(notificationPermission: .undecided)

public enum NotificationPermission: String, Equatable, Codable {
    case undecided
    case allowed
    case denied
}
