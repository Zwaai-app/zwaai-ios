import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic

class OnlyOneSpaceCheckedInAtTheTimeSpec: QuickSpec {
    override func spec() {
        let space1 = testSpace(name: "space1", description: "desc1")
        let space2 = testSpace(name: "space2", description: "desc2")

        var store: ReduxStoreBase<AppAction, AppState>!

        beforeEach {
            store = ReduxStoreBase(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: unitTestSafeAppMiddleware)
        }

        context("when user is checked in in a space") {
            beforeEach {
                let item1 = HistoryItem(
                    id: UUID(),
                    timestamp: Date(timeIntervalSinceNow: -300),
                    type: .space(space: space1))
                store.dispatch(.history(.addItem(item: item1)))
                var receivedState: AppState?
                let cancellable = store.statePublisher.sink { appState in
                    receivedState = appState
                }
                expect(receivedState?.zwaai.checkedIn).toEventually(equal(space1))
                let entries = receivedState!.history.entries
                expect(entries).toEventually(haveCount(1))
                expect(entries.last!.type.space?.id) == space1.id
                expect(entries.last!.type.space!.checkedOut).to(beNil())

                cancellable.cancel()
            }

            it("a new checkin causes checkout of previous") {
                // Checkin in space 2
                let item2 = HistoryItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: .space(space: space2))
                var receivedState: AppState?
                let cancellable = store.statePublisher.sink { appState in
                    receivedState = appState
                }
                store.dispatch(.history(.addItem(item: item2)))
                expect(receivedState?.zwaai.checkedIn).toEventually(equal(space2))

                // There should be two entries now:
                //
                //    index 0 (newest): check in of space 2
                //    index 1 (oldest): space 1 with checkedOut date

                let entries = receivedState!.history.entries
                expect(entries).toEventually(haveCount(2))
                expect(entries.first!.type.space) == space2
                expect(entries.first!.type.space?.checkedOut).to(beNil())

                expect(entries.last!.type.space?.id) == space1.id
                expect(abs(entries.last!.type.space!.checkedOut!.timeIntervalSinceNow)) < 5

                cancellable.cancel()
            }
        }
    }
}
