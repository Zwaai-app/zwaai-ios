import Foundation
import SwiftRex

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
}

var autoCheckoutTimer: Timer?
