import Quick
import Nimble
import SwiftRex
import Combine
@testable import ZwaaiLogic

class AutoCheckoutMiddlewareSpec: QuickSpec {
    override func spec() {
        var store: ReduxStoreBase<AppAction, AppState>!
        var cancellable: AnyCancellable!
        var receivedState: AppState?

        func setupStore(initialState: AppState) {
            store = ReduxStoreBase(
                subject: .combine(initialValue: initialState),
                reducer: appReducer,
                middleware: unitTestSafeAppMiddleware
            )
            cancellable = store.statePublisher.sink { appState in
                receivedState = appState
            }
        }

        beforeEach {
            receivedState = nil
            autoCheckoutTimer = nil
        }

        afterEach {
            cancellable.cancel()
        }

        context("given initial store") {
            beforeEach {
                setupStore(initialState: initialAppState)
            }

            it("does not schedule a timer") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventually(beNil())
            }
        }

        context("when checked in with auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: 1800,
                                       deadline: Date(timeIntervalSinceNow: 300))
                setupStore(initialState: AppState(history: initialHistoryState,
                                                  zwaai: ZwaaiState(checkedIn: space),
                                                  meta: initialMetaState))
            }

            it("schedules a timer for auto checkout deadline") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventuallyNot(beNil())
                expect(abs(autoCheckoutTimer!.fireDate.timeIntervalSince(space.deadline!))) < 1
            }
        }

        context("when deadline is about to pass") {
            var space: CheckedInSpace!

            beforeEach {
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: 1800,
                                       deadline: Date(timeIntervalSinceNow: 1))
                setupStore(initialState: AppState(history: initialHistoryState,
                                                  zwaai: ZwaaiState(checkedIn: space),
                                                  meta: initialMetaState))
            }

            it("schedules a timer and checks out in that timer") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventuallyNot(beNil())
                expect(receivedState?.zwaai.checkedIn).toEventually(beNil(), timeout: 2)
            }
        }

        context("when deadline has already passed") {
            var space: CheckedInSpace!

            beforeEach {
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: 1800,
                                       deadline: Date(timeIntervalSinceNow: -60))
                setupStore(initialState: AppState(
                    history: historyState(entries: [
                        HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -1800-60),
                                    type: .space(space: space), random: Random())
                    ]),
                    zwaai: ZwaaiState(checkedIn: space),
                    meta: initialMetaState))
            }

            it("immediately checks out") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedIn).toEventually(beNil())
            }

            it("uses deadline for the history") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(receivedState?.history.entries.first?.type.space?.checkedOut).toEventuallyNot(beNil())
                let checkoutDate = receivedState?.history.entries.first?.type.space?.checkedOut
                expect(abs(checkoutDate!.timeIntervalSinceNow + 60)).toEventually(beLessThan(1))
            }
        }

        context("when checked in without auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                autoCheckoutTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { _ in }
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: nil,
                                       deadline: nil)
                setupStore(initialState: AppState(history: initialHistoryState,
                                                  zwaai: ZwaaiState(checkedIn: space),
                                                  meta: initialMetaState))
            }

            it("does not checkout and sets no timer") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedIn).toEventuallyNot(beNil())
            }
        }

        context("when checking in without auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: nil)
                setupStore(initialState: initialAppState)
            }

            it("does not set auto checkout timer") {
                store.dispatch(.zwaai(.checkin(space: space)))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedIn).toEventuallyNot(beNil())
            }
        }

        context("when checking in with auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                space = CheckedInSpace(name: "test",
                                       description: "test",
                                       autoCheckout: 1)
                setupStore(initialState: initialAppState)
            }

            it("schedules a timer and checks out in that timer") {
                store.dispatch(.zwaai(.checkin(space: space)))
                expect(autoCheckoutTimer).toEventuallyNot(beNil())
                expect(receivedState?.zwaai.checkedIn).toEventually(beNil(), timeout: 2)
            }
        }
    }
}
