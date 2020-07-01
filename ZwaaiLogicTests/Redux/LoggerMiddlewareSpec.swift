import Quick
import Nimble
import SwiftRex
@testable import ZwaaiLogic

class LoggerMiddlewareSpec: QuickSpec {
    override func spec() {
        var loggerMiddleware: MemoryLoggerMiddleware!
        var liftedLoggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>!
        var store: ReduxStoreBase<AppAction, AppState>!

        beforeEach {
            loggerMiddleware = MemoryLoggerMiddleware()
            loggerMiddleware.reset()
            liftedLoggerMiddleware = loggerMiddleware.lift(outputActionMap: absurd).eraseToAnyMiddleware()
            store = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialAppState),
                reducer: appReducer,
                middleware: liftedLoggerMiddleware
            )
        }

        it("logs action and state details") {
            let action = AppAction.history(.lock)
            store.dispatch(action)
            var stateAfter: AppState!
            let cancellable = store.statePublisher.sink(receiveValue: { (appState: AppState) in
                stateAfter = appState
            })

            expect(loggerMiddleware.logLines.count).toEventually(beGreaterThan(0))

            let lines = loggerMiddleware.logLines
            let stateBeforeLines = lines.filter { $0.contains("State before:") }
            let actionLines = lines.filter { $0.contains("Action:") }
            let stateAfterLines = lines.filter { $0.contains("State after:") }

            expect(stateBeforeLines).to(haveCount(1))
            expect(actionLines).to(haveCount(1))
            expect(stateAfterLines).to(haveCount(1))

            expect(stateBeforeLines[0]).to(contain(String(describing: initialAppState)))
            expect(actionLines[0]).to(contain(String(describing: action)))
            expect(stateAfterLines[0]).to(contain(String(describing: stateAfter!)))

            cancellable.cancel()
        }
    }
}

class MemoryLoggerMiddleware: LoggerMiddleware {
    var logLines: [String]

    override init() {
        logLines = []
        super.init()
        self.log = { (items: Any...) in self.logLines.append(String(describing: items)) }
    }

    func reset() {
        logLines = []
    }
}
