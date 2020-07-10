import Quick
import Nimble
import SwiftCheck
@testable import ZwaaiLogic

class AppMetaReducerSpec: QuickSpec {
    override func spec() {
        it("reduces didSaveState(result:)") {
            let action = AppMetaAction.didSaveState(result: .success(Date()))
            let newState = appMetaReducer.reduce(action, initialMetaState)
            expect(newState.lastSaved) == action.didSaveState
        }

        it("reduces set(systemNotificationPermission:)") {
            let action = AppMetaAction.set(systemNotificationPermission: .authorized)
            let newState = appMetaReducer.reduce(action, initialMetaState)
            expect(newState.systemNotificationPermission) == .authorized
        }
    }
}