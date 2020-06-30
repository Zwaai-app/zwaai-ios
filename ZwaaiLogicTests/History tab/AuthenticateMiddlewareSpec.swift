import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic
import LocalAuthentication

class AuthenticateMiddlewareSpec: QuickSpec {
    override func spec() {
        var store: ReduxStoreBase<AppAction, AppState>!
        var authMiddleware: AuthenticateMiddleware!
        var mockContext: LAContextMock!

        beforeEach {
            mockContext = LAContextMock()
            authMiddleware = AuthenticateMiddleware()
            authMiddleware.createLAContext = { return mockContext }
            store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: authMiddleware
            )
        }

        context("when policy not available") {
            beforeEach {
                mockContext.canEvaluate = false
            }

            it("unlocks because locking makes no sense") {
                store.dispatch(AppAction.history(.tryUnlock))
                var receivedState: AppState?
                let cancellable = store.statePublisher.sink(receiveCompletion: ignore, receiveValue: { appState in
                    receivedState = appState
                })
                expect(receivedState?.history.lock).toEventually(equal(.unlocked))
                cancellable.cancel()
            }
        }

        context("when user fails to authenticate") {
            beforeEach {
                mockContext.canEvaluate = true
                mockContext.authResult = false
            }

            it("fails unlocking") {
                store.dispatch(AppAction.history(.tryUnlock))
                var receivedState: AppState?
                let cancellable = store.statePublisher.sink(receiveCompletion: ignore, receiveValue: { appState in
                    receivedState = appState
                })
                expect(receivedState?.history.lock).toEventually(equal(.locked))
                cancellable.cancel()
            }
        }

        context("when user authenticates") {
            beforeEach {
                mockContext.canEvaluate = true
                mockContext.authResult = true
            }

            it("unlocks") {
                store.dispatch(AppAction.history(.tryUnlock))
                var receivedState: AppState?
                let cancellable = store.statePublisher.sink(receiveCompletion: ignore, receiveValue: { appState in
                    receivedState = appState
                })
                expect(receivedState?.history.lock).toEventually(equal(.unlocked))
                cancellable.cancel()
            }
        }
    }
}

class LAContextMock: LAContextProtocol {
    var canEvaluate = false
    var authResult = false
    var replyError: Error?

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEvaluate
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        reply(authResult, replyError)
    }
}
