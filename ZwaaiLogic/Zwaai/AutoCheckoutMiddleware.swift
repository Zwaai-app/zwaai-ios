import Foundation
import SwiftRex
import UIKit

public class AutoCheckoutMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = ZwaaiAction
    public typealias StateType = ZwaaiState

    var getState: GetState<ZwaaiState>?
    var output: AnyActionHandler<ZwaaiAction>?

    public func receiveContext(getState: @escaping GetState<ZwaaiState>, output: AnyActionHandler<ZwaaiAction>) {
        self.getState = getState
        self.output = output
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if action.meta?.isSetupAutoCheckout ?? action.zwaai?.isCheckin ?? false {
            afterReducer = .do {
                if let checkedIn = self.getState?().checkedIn,
                    let deadline = checkedIn.deadline {
                    if deadline > Date() {
                        autoCheckoutTimer = Timer.scheduledTimer(
                            withTimeInterval: deadline.timeIntervalSinceNow,
                            repeats: false) { _ in
                                self.output?.dispatch(.checkout(space: checkedIn))
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                if let controller = UIApplication.currentWindow?.rootViewController {
                                    self.showDidAutoCheckoutMessage(on: controller, space: checkedIn)
                                }
                        }
                    } else {
                        self.output?.dispatch(.checkout(space: checkedIn))
                    }
                } else {
                    autoCheckoutTimer?.invalidate()
                    autoCheckoutTimer = nil
                }
            }
        } else if action.zwaai?.isCheckout ?? false {
            autoCheckoutTimer?.invalidate()
            autoCheckoutTimer = nil
        }
    }

    func showDidAutoCheckoutMessage(on controller: UIViewController, space: CheckedInSpace) {
        let title = NSLocalizedString(
            "Ruimte is automatisch verlaten",
            comment: "auto checkout local notification title")
        let formatString = NSLocalizedString(
            "De ruimte %@ is automatisch verlaten omdat de tijd verstreken is. Als u nog in de ruimte bent, kunt u handmatig opnieuw inchecken.", // swiftlint:disable:this line_length
            comment: "auto checkout local notification body")
        let alert = UIAlertController(
            title: title,
            message: String.localizedStringWithFormat(formatString, space.name),
            preferredStyle: .alert)
        let dismiss = NSLocalizedString("Oké", comment: "dismiss button on alert")
        alert.addAction(.init(title: dismiss, style: .default, handler: nil))
        controller.present(alert, animated: true)
    }
}

var autoCheckoutTimer: Timer?
