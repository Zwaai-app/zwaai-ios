import Foundation
import SwiftRex
import UIKit

public class ZwaaiFeedbackMiddleware: Middleware {
    public typealias InputActionType = AppMetaAction
    public typealias OutputActionType = Never
    public typealias StateType = Void

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<Never>) {}

    public func handle(action: AppMetaAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if case let .zwaaiSucceeded(presentingController, onDismiss) = action {
            DispatchQueue.main.async {
                HapticFeedback.default.zwaaiSucceeded()
                AudioFeedback.default.playWaved()
                let alert = succeededAlert(onDismiss: onDismiss)
                presentingController.present(alert, animated: true)
            }
        } else if case let .zwaaiFailed(presentingController, onDismiss) = action {
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
