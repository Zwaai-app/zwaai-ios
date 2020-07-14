import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic

class PersistStateMiddlewareSpec: QuickSpec {
    override func spec() {
        var store: ReduxStoreBase<AppAction, AppState>!
        var captureDispatches: CaptureDispatchesMiddleware!
        var persistStateMiddleware: PersistStateMiddleware!
        var saveSpy: SaveSpy!

        beforeEach {
            saveSpy = SaveSpy()
            persistStateMiddleware = PersistStateMiddleware()
            persistStateMiddleware.persistState = saveSpy.saveAppState(state:)
            captureDispatches = CaptureDispatchesMiddleware()
            store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: persistStateMiddleware
                    <>
                    captureDispatches.lift(stateMap: ignore)
            )
        }

        it("ignores meta actions") {
            let action = AppAction.meta(.didSaveState(result: .failure(.noUserDocumentsDirectory)))
            store.dispatch(action)
            expect(captureDispatches.observedActions) == [action]
            expect(saveSpy.didSaveCount) == 0
        }

        it("dispatches didSave on other actions") {
            let action = AppAction.resetAppState
            store.dispatch(action)
            expect(captureDispatches.observedActions).toEventually(haveCount(2))
            expect(captureDispatches.observedActions[0]) == action
            expect(captureDispatches.observedActions[1].meta?.isDidSaveState).to(beTrue())
            let date = try! captureDispatches.observedActions[1].meta!.didSaveState!.get()
            expect(abs(date.timeIntervalSinceNow)) < 5
            expect(saveSpy.didSaveCount) == 1
        }
    }
}

class SaveSpy {
    var didSaveCount = 0

    func saveAppState(state: AppState) -> Result<Date, AppError> {
        didSaveCount += 1
        return .success(Date())
    }
}
