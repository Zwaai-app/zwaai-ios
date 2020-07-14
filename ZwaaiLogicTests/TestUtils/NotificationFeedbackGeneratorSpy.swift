@testable import ZwaaiLogic
import UIKit

class NotificationFeedbackGeneratorSpy: NotificationFeedbackGeneratorProto {
    var occurredNotifications = [UINotificationFeedbackGenerator.FeedbackType]()

    func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        occurredNotifications.append(notificationType)
    }
}
