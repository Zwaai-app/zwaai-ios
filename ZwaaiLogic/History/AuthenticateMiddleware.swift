import Foundation
import Combine
import SwiftRex
import LocalAuthentication
import SwiftUI

public class AuthenticateMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = AppAction
    public typealias StateType = AppState

    // start of boilerplate
    // there are other higher level middlewares implementations
    // that hide most of this code, we're showing the complete
    // stuff to go very basic
    init() { }

    private var getState: GetState<AppState>!
    private var output: AnyActionHandler<AppAction>!
    var createLAContext: () -> LAContextProtocol = { return LAContext() }

    public func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<AppAction>) {
        self.getState = getState
        self.output = output
    }
    // end of boilerplate
}

extension AuthenticateMiddleware {
    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        switch action {
        case .history(.tryUnlock): tryAuthentication()
        default: break
        }
    }

    func tryAuthentication() {
        let context = createLAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            authenticate(context: context)
        } else {
            // If the user cannot authenticate, it probably means there
            // is no device passcode set (anymore), so we'll just unlock.
            // This is a defensive-programming measure, the idea is that
            // the UI doesn't even provide the ability to lock in this case.
            self.output.dispatch(.history(.unlockSucceeded))
        }
    }

    func authenticate(context: LAContextProtocol) {
        let reason = NSLocalizedString(
            "Als eigenaar van dit toestel bepaalt u of de geschiedenis zichtbaar is.",
            comment: "Reason for which auth is requested: show history")
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, _ in
            self.output.dispatch(.history(success ? .unlockSucceeded : .unlockFailed))
        }

    }
}

protocol LAContextProtocol {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
}

extension LAContext: LAContextProtocol {}
