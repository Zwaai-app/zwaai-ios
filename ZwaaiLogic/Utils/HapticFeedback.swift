import Foundation
import UIKit

class HapticFeedback {
    static var `default`
        = HapticFeedback(feedbackGenerator: UINotificationFeedbackGenerator())

    let feedbackGenerator: NotificationFeedbackGeneratorProto

    init(feedbackGenerator: NotificationFeedbackGeneratorProto) {
        self.feedbackGenerator = feedbackGenerator
    }

    func zwaaiSucceeded() {
        feedbackGenerator.notificationOccurred(.success)
    }

    func zwaaiFailed() {
        feedbackGenerator.notificationOccurred(.error)
    }

    func didAutoCheckout() {
        feedbackGenerator.notificationOccurred(.success)
    }
}

protocol NotificationFeedbackGeneratorProto {
    func notificationOccurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType)
}
extension UINotificationFeedbackGenerator: NotificationFeedbackGeneratorProto {}
