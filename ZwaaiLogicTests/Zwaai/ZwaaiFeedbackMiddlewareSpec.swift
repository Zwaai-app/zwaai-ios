import Quick
import Nimble
@testable import ZwaaiLogic
import SwiftRex
import UIKit

class ZwaaiFeedbackMiddlewareSpec: QuickSpec {
    override func spec() {
        it("can create a succeeded alert") {
            var onDismissCalled = false
            let alert = succeededAlert(onDismiss: { onDismissCalled = true })
            expect(alert.title) == "Gelukt"
            expect(alert.message).to(contain("Het uitwisselen van de random is gelukt"))
            expect(alert.actions).to(haveCount(1))
            expect(alert.actions.first?.title) == "Verder"
            alert.tapButton(atIndex: 0)
            expect(onDismissCalled) == true
        }

        it("can create a failed alert") {
            var onDismissCalled = false
            let alert = failedAlert(onDismiss: { onDismissCalled = true })
            expect(alert.title) == "Mislukt"
            expect(alert.message).to(contain("Het uitwisselen van de random is niet gelukt"))
            expect(alert.actions).to(haveCount(1))
            expect(alert.actions.first?.title) == "Nogmaals"
            alert.tapButton(atIndex: 0)
            expect(onDismissCalled) == true
        }

        describe("middleware handler") {
            var feedbackGeneratorSpy: NotificationFeedbackGeneratorSpy!
//            var audioPlayerSpy: AudioPlayerSpy!
            var middleware: ZwaaiFeedbackMiddleware!
            var controllerSpy: ViewControllerSpy!
            var audioPlayerSpy: AudioPlayerSpy?

            beforeEach {
                audioPlayerSpy = nil
                feedbackGeneratorSpy = NotificationFeedbackGeneratorSpy()
                HapticFeedback.default = HapticFeedback(feedbackGenerator: feedbackGeneratorSpy)
                let audioDeps = AudioDeps(
                    createPlayer: { url in
                        let spy = try AudioPlayerSpy(contentsOf: url)
                        audioPlayerSpy = spy
                        return spy },
                    audioSession: AudioSessionSpy())
                AudioFeedback.default = AudioFeedback(deps: audioDeps)
                middleware = ZwaaiFeedbackMiddleware()
                controllerSpy = ViewControllerSpy()
            }

            context("on zwaaiSucceceded for person") {
                beforeEach {
                    var afterReducer: AfterReducer = .identity
                    let url = ZwaaiURL(type: .person(random: Random()))
                    middleware.handle(
                        action: .meta(.zwaaiSucceeded(url: url, presentingController: controllerSpy, onDismiss: {})),
                        from: .here(),
                        afterReducer: &afterReducer)
                }

                it("triggers haptic feedback") {
                    expect(feedbackGeneratorSpy.occurredNotifications).toEventually(equal([.success]))
                }

                it("presented an alert") {
                    expect(controllerSpy.presentedController).toEventually(beAKindOf(UIAlertController.self))
                    expect((controllerSpy.presentedController as? UIAlertController)?.title) == "Gelukt"
                }

                it("played a sound") {
                    expect(audioPlayerSpy?.playCount).toEventually(be(1))
                }
            }

            context("on zwaaiSucceeded for space") {
                let space = testSpace()
                let url = ZwaaiURL(type: .space(space: space))
                var actionHandlerSpy: ActionHandlerSpy!

                beforeEach {
                    actionHandlerSpy = ActionHandlerSpy()
                    let output = actionHandlerSpy.eraseToAnyActionHandler()
                    middleware.receiveContext(getState: {initialMetaState}, output: output)

                    var afterReducer: AfterReducer = .identity
                    middleware.handle(
                        action: .meta(.zwaaiSucceeded(url: url, presentingController: controllerSpy, onDismiss: {})),
                        from: .here(),
                        afterReducer: &afterReducer)
                }

                it("triggers haptic feedback") {
                    expect(feedbackGeneratorSpy.occurredNotifications).toEventually(equal([.success]))
                }

                it("played a sound") {
                    expect(audioPlayerSpy?.playCount).toEventually(be(1))
                }

                it("dispatches feedback continuation") {
                    expect(actionHandlerSpy.dispatchedActions).toEventually(haveCount(1))
                    guard let continuation = actionHandlerSpy.dispatchedActions.first?
                        .meta?.setFeedbackContinuation else {
                        fail("no feedback continuation")
                        return
                    }
                    expect(continuation.url) == url
                }
            }

            it("shows alert on checkin succeeded") {
                let space = testSpace()
                let url = ZwaaiURL(type: .space(space: space))
                var state = initialMetaState
                state.feedbackContinuation = FeedbackContinuation(url: url,
                                                                  presentingController: controllerSpy,
                                                                  onDismiss: {})
                let output = ActionHandlerSpy().eraseToAnyActionHandler()
                middleware.receiveContext(getState: { state }, output: output)
                var afterReducer: AfterReducer = .identity
                middleware.handle(
                    action: .zwaai(.checkinSucceeded(space: space)),
                    from: .here(),
                    afterReducer: &afterReducer)

                expect(controllerSpy.presentedController).toEventually(beAKindOf(UIAlertController.self))
                expect((controllerSpy.presentedController as? UIAlertController)?.title) == "Gelukt"
            }

            it("shows alert on checkin failed") {
                let space = testSpace()
                let url = ZwaaiURL(type: .space(space: space))
                var state = initialMetaState
                state.feedbackContinuation = FeedbackContinuation(url: url,
                                                                  presentingController: controllerSpy,
                                                                  onDismiss: {})
                let output = ActionHandlerSpy().eraseToAnyActionHandler()
                middleware.receiveContext(getState: { state }, output: output)
                var afterReducer: AfterReducer = .identity
                middleware.handle(
                    action: .zwaai(.checkinFailed(reason: "test reason")),
                    from: .here(),
                    afterReducer: &afterReducer)

                expect(controllerSpy.presentedController).toEventually(beAKindOf(UIAlertController.self))
                expect((controllerSpy.presentedController as? UIAlertController)?.title) == "Mislukt"
            }

            context("on zwaaiFailed") {
                beforeEach {
                    var afterReducer: AfterReducer = .identity
                    middleware.handle(
                        action: .meta(.zwaaiFailed(presentingController: controllerSpy, onDismiss: {})),
                        from: .here(),
                        afterReducer: &afterReducer)
                }

                it("triggers haptic feedback") {
                    expect(feedbackGeneratorSpy.occurredNotifications).toEventually(equal([.error]))
                }

                it("played a sound") {
                    expect(audioPlayerSpy?.playCount).toEventually(be(1))
                }

                it("presented an alert") {
                    expect(controllerSpy.presentedController).toEventually(beAKindOf(UIAlertController.self))
                    expect((controllerSpy.presentedController as? UIAlertController)?.title) == "Mislukt"
                }
            }
        }
    }
}

private extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}

private class ViewControllerSpy: UIViewController {
    var presentedController: UIViewController?
    var animated: Bool?

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presentedController = viewControllerToPresent
    }
}
