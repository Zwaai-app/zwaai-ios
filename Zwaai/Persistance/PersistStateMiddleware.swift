import Foundation
import SwiftRex

class PersistStateMiddleware: Middleware {
    typealias InputActionType = AppAction
    typealias OutputActionType = Never
    typealias StateType = AppState

    var getState: GetState<AppState>!

    func receiveContext(getState: @escaping GetState<AppState>, output: AnyActionHandler<Never>) {
        self.getState = getState

    }

    func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        afterReducer = .do {
            let state = self.getState()

            let encoder = JSONEncoder()
            let out: Data
            do {
                out = try encoder.encode(state)
                guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let file = docDir.appendingPathComponent("zwaai-state.json")
                try out.write(to: file, options: [.atomic, .completeFileProtection])
            }
            catch (let e) {
                print("[error] Failed to encode state: ", e)
            }
        }
    }
}
