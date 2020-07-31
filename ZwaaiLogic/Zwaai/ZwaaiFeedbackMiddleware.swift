import Foundation
import SwiftRex
import UIKit

public class ZwaaiFeedbackMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = AppAction
    public typealias StateType = AppMetaState

    var getState: GetState<AppMetaState>?
    var output: AnyActionHandler<AppAction>?

    public func receiveContext(getState: @escaping GetState<AppMetaState>,
                               output: AnyActionHandler<AppAction>) {
        self.getState = getState
        self.output = output
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .meta(.zwaaiSucceeded(url, presentingController, onDismiss)) = action {
            DispatchQueue.main.async {
                HapticFeedback.default.zwaaiSucceeded()
                AudioFeedback.default.playWaved()
                if url.type.isPerson {
                    let alert = succeededAlert(onDismiss: onDismiss)
                    presentingController.present(alert, animated: true)
                } else {
                    // alert should be displayed on checkinSucceeded / checkinFailed;
                    // as presenting controller we use the rootViewController, because
                    // the presenting controller passed in this action may be gone by
                    // the time the alert is displayed.
                    let continuation = FeedbackContinuation(
                        url: url,
                        presentingController: UIApplication.currentWindow?.rootViewController,
                        onDismiss: onDismiss)
                    self.output?.dispatch(.meta(.setFeedbackContinuation(continuation: continuation)))
                }
            }
        } else if action.zwaai?.isCheckinSucceeded ?? false {
            if let continuation = self.getState?().feedbackContinuation {
                let alert = succeededAlert(onDismiss: continuation.onDismiss)
                let presentingController = continuation.presentingController
                presentingController?.present(alert, animated: true)
                self.output?.dispatch(.meta(.clearFeedbackContinuation))
            }
        } else if action.zwaai?.isCheckinFailed ?? false {
            if let continuation = self.getState?().feedbackContinuation {
                let alert = failedAlert(onDismiss: continuation.onDismiss)
                let presentingController = continuation.presentingController
                presentingController?.present(alert, animated: true)
                self.output?.dispatch(.meta(.clearFeedbackContinuation))
            }
        } else if case let .meta(.zwaaiFailed(presentingController, onDismiss)) = action {
            DispatchQueue.main.async {
                HapticFeedback.default.zwaaiFailed()
                AudioFeedback.default.playWaved()
                let alert = failedAlert(onDismiss: onDismiss)
                presentingController.present(alert, animated: true)
            }
        }
    }
}

public func succeededAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString(
        "Success",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan succeeded alert title")
    let message = NSLocalizedString(
        "scan succeeded alert message",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan succeeded alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString(
        "Proceed",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan succeeded alert dismiss button label")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .default, handler: { _ in onDismiss() }
    ))
    return alert
}

public func failedAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString(
        "Failed",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan failed alert title")
    let message = NSLocalizedString(
        "scan failed alert message",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan failed alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString(
        "Retry",
        tableName: "ZwaaiFeedback",
        bundle: .zwaaiLogic,
        comment: "Scan failed alert dismiss button label")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .destructive, handler: { _ in onDismiss() }
    ))
    return alert
}
