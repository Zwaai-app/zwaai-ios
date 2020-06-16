import Foundation
import Combine
import SwiftRex
import LocalAuthentication
import SwiftUI

class AuthenticateMiddleware: Middleware {
    // start of boilerplate
    // there are other higher level middlewares implementations
    // that hide most of this code, we're showing the complete
    // stuff to go very basic
    init() { }

    private var getState: GetState<AppState>!
    private var output: AnyActionHandler<AppAction>!
    func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<AppAction>) {
        self.getState = getState
        self.output = output
    }
    // end of boilerplate
}

extension AuthenticateMiddleware {
    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        switch action {
        case .history(.tryUnlock):
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = NSLocalizedString("Als eigenaar van dit toestel bepaalt u of de geschiedenis zichtbaar is.", comment: "Reason for which auth is requested: show history")
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                    self.output.dispatch(.history(success ? .unlockSucceeded : .unlockFailed))
                }
            } else {
                // If the user cannot authenticate, it probably means there
                // is no device passcode set (anymore), so we'll just unlock.
                // This is a defensive-programming measure, the idea is that
                // the UI doesn't even provide the ability to lock in this case.
                self.output.dispatch(.history(.unlockSucceeded))
            }
        default:
            break
        }
    }
}
