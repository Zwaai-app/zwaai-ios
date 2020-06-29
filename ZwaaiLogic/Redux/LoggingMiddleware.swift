import Foundation
import Combine
import SwiftRex

public class LoggerMiddleware: Middleware {
    public typealias InputActionType = AppAction // It wants to receive all possible app actions
    public typealias OutputActionType = Never    // No action is generated from this Middleware
    public typealias StateType = AppState        // It wants to read the whole app state

    var getState: GetState<AppState>!

    public func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<Never>) {
        self.getState = getState
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        let stateBefore: AppState = getState()
        let dateBefore = Date()

        afterReducer = .do {
            let stateAfter = self.getState()
//            let dateAfter = Date()
            let sourceFile = URL(fileURLWithPath: dispatcher.file)
            let sourceFileName = sourceFile.pathComponents.last
            let source = "\(sourceFileName!):\(dispatcher.line) - \(dispatcher.function) | \(dispatcher.info ?? "")"

            print("--------------------------------- \(dateBefore) ---------------------------------")
            print("  State before: ", stateBefore)
            print("        Action: ", action)
            print("   State after: ", stateAfter)
            print("        Source: ", source)
        }
    }
}
