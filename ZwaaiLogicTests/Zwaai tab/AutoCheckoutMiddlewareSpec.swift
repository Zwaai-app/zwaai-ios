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
                space = testSpace(autoCheckout: 1800,
                                  deadline: Date(timeIntervalSinceNow: 300))
                setupStore(initialState: appState(zwaai: ZwaaiState(checkedInStatus: .succeeded(value: space))))
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
                space = testSpace(autoCheckout: 1800,
                                  deadline: Date(timeIntervalSinceNow: 1))
                setupStore(initialState: appState(zwaai: ZwaaiState(checkedInStatus: .succeeded(value: space))))
            }

            it("schedules a timer and checks out in that timer") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventuallyNot(beNil())
                expect(receivedState?.zwaai.checkedInStatus).toEventually(beNil(), timeout: 2)
            }
        }

        context("when deadline has already passed") {
            var space: CheckedInSpace!

            beforeEach {
                space = testSpace(autoCheckout: 1800,
                                  deadline: Date(timeIntervalSinceNow: -60))
                setupStore(initialState: appState(
                    history: historyState(entries: [
                        HistoryItem(id: UUID(), timestamp: Date(timeIntervalSinceNow: -1800-60),
                                    type: .space(space: space))
                    ]),
                    zwaai: ZwaaiState(checkedInStatus: .succeeded(value: space))))
            }

            it("immediately checks out") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedInStatus).toEventually(beNil())
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
                space = testSpace()
                setupStore(initialState: appState(zwaai: ZwaaiState(checkedInStatus: .succeeded(value: space))))
            }

            it("does not checkout and sets no timer") {
                store.dispatch(.meta(.setupAutoCheckout))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedInStatus).toEventuallyNot(beNil())
            }
        }

        context("when checking in without auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                space = testSpace()
                setupStore(initialState: initialAppState)
            }

            it("does not set auto checkout timer") {
                store.dispatch(.zwaai(.checkinSucceeded(space: space)))
                expect(autoCheckoutTimer).toEventually(beNil())
                expect(receivedState?.zwaai.checkedInStatus).toEventuallyNot(beNil())
            }
        }

        context("when checking in with auto checkout") {
            var space: CheckedInSpace!

            beforeEach {
                space = testSpace(autoCheckout: 1)
                setupStore(initialState: initialAppState)
            }

            it("schedules a timer and checks out in that timer") {
                store.dispatch(.zwaai(.checkinSucceeded(space: space)))
                expect(autoCheckoutTimer).toEventuallyNot(beNil())
                expect(receivedState?.zwaai.checkedInStatus?.succeeded).toEventually(beNil(), timeout: 2)
            }
        }

        context("when checking out") {
            var space: CheckedInSpace!

            beforeEach {
                space = testSpace(autoCheckout: 1)
                setupStore(initialState: initialAppState)
                autoCheckoutTimer = Timer.scheduledTimer(withTimeInterval: 60,
                                                         repeats: false,
                                                         block: {_ in })
            }

            it("invalidates timer") {
                store.dispatch(.zwaai(.checkout(space: space)))
                expect(autoCheckoutTimer).toEventually(beNil())
            }
        }
    }
}
