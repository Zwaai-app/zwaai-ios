import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic
import LocalAuthentication

class DidScanURLMiddlewareSpec: QuickSpec {
    override func spec() {
        var store: ReduxStoreBase<AppAction, AppState>!
        var captureDispatches: CaptureDispatchesMiddleware!

        beforeEach {
            captureDispatches = CaptureDispatchesMiddleware()
            store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: captureDispatches.lift(stateMap: ignore)
                    <> didScanURLMiddleware
            )
        }

        it("parses a person URL and dispatches addItem when it succeeds") {
            let random = Random()
            let url = ZwaaiURL(type: .person(random: random))
            let addEntryAction = AppAction.history(.addEntry(url: url))
            store.dispatch(addEntryAction)

            expect(captureDispatches.observedActions).toEventually(haveCount(2))
            let item = captureDispatches.observedActions[1].history!.addItem!
            expect(item.type) == .person(random: random)
            expect(abs(item.timestamp.timeIntervalSinceNow)) < 5
        }

        it("parses a space URL and dispatches addItem when it succeeds") {
            let space = testSpace(name: "test", description: "testDesc", autoCheckout: nil)
            let url = ZwaaiURL(type: .space(space: space))
            let addEntryAction = AppAction.history(.addEntry(url: url))
            store.dispatch(addEntryAction)

            expect(captureDispatches.observedActions).toEventually(haveCount(3))
            let item = captureDispatches.observedActions[1].history!.addItem!
            expect(item.type.isSpace).to(beTrue())
            expect(abs(item.timestamp.timeIntervalSinceNow)) < 5
            expect(item.type.space?.name) == "test"
            expect(item.type.space?.description) == "testDesc"
            expect(item.type.space?.autoCheckout).to(beNil())

            expect(captureDispatches.observedActions[2].zwaai?.isCheckin).to(beTrue())
        }
    }
}
