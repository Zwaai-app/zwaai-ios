import Foundation
import Combine
import SwiftRex

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

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        switch action {
        case .history(.tryUnlock):
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.output.dispatch(.history(.unlockSucceeded))
            }
        default:
            break
        }
    }
}
