import Quick
import Nimble
@testable import ZwaaiLogic

class HapticFeedbackSpec: QuickSpec {
    override func spec() {
        var feedbackGeneratorSpy: NotificationFeedbackGeneratorSpy!
        var hapticFeedback: HapticFeedback!

        beforeEach {
            feedbackGeneratorSpy = NotificationFeedbackGeneratorSpy()
            hapticFeedback = HapticFeedback(feedbackGenerator: feedbackGeneratorSpy)
        }

        it("triggers success on zwaaiSucceeded") {
            hapticFeedback.zwaaiSucceeded()
            expect(feedbackGeneratorSpy.occurredNotifications) == [.success]
        }

        it("triggers error on zwaaiFailed") {
            hapticFeedback.zwaaiFailed()
            expect(feedbackGeneratorSpy.occurredNotifications) == [.error]
        }

        it("triggers success on auto checkout") {
            hapticFeedback.didAutoCheckout()
            expect(feedbackGeneratorSpy.occurredNotifications) == [.success]
        }
    }
}
