import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic

class UpdateHistoryOnCheckoutMiddlewareSpec: QuickSpec {
    override func spec() {
        var store: ReduxStoreBase<AppAction, AppState>!

        beforeEach {
            store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: unitTestSafeAppMiddleware
                    // <> loggerMiddleware
            )
        }

        it("updates history when checking in and out") {
            let space = testSpace()
            let item = HistoryItem(id: UUID(), timestamp: Date(), type: .space(space: space))

            var updateStateCount = 0
            var receivedState: AppState!
            store.dispatch(AppAction.history(.addItem(item: item)))
            let cancellable = store.statePublisher.sink(receiveCompletion: ignore, receiveValue: { appState in
                updateStateCount += 1
                receivedState = appState
            })

            expect(receivedState.zwaai.checkedIn?.id).toEventually(equal(space.id))
            expect(receivedState.history.entries).to(haveCount(1))
            expect(receivedState.history.entries[0].type.space?.id) == space.id
            expect(receivedState.history.entries[0].type.space?.checkedOut).to(beNil())
            expect(updateStateCount) == 2

            store.dispatch(AppAction.zwaai(.checkout(space: space)))
            expect(receivedState.zwaai.checkedIn?.id).toEventually(beNil())
            expect(receivedState.history.entries).to(haveCount(1))
            expect(receivedState.history.entries[0].type.space?.id) == space.id
            expect(receivedState.history.entries[0].type.space?.checkedOut).toNot(beNil())
            expect(updateStateCount) == 4

            cancellable.cancel()
        }
    }
}
