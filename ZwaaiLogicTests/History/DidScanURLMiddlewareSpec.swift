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
            let addEntryAction = AppAction.zwaai(.didScan(url: url))
            store.dispatch(addEntryAction)

            expect(captureDispatches.observedActions).toEventually(haveCount(2))
            let item = captureDispatches.observedActions[1].history!.addItem!
            expect(item.type) == .person(random: random)
            expect(abs(item.timestamp.timeIntervalSinceNow)) < 5
        }
    }
}

class DidScanURLMiddlewarePiecesSpec: QuickSpec {
    override func spec() {
        let space = testSpace()
        let url = ZwaaiURL(type: .space(space: space))
        var didScanMiddleware: DidScanURLMiddleware!
        var actionHandlerSpy: ActionHandlerSpy!

        beforeEach {
            didScanMiddleware = DidScanURLMiddleware()
            actionHandlerSpy = ActionHandlerSpy()
            let output = actionHandlerSpy.eraseToAnyActionHandler()
            didScanMiddleware.receiveContext(getState: {}, output: output)
        }

        context("given that server request fails") {
            var combineLocationWithTimeTestDouble: CombineLocationWithTimeTestDouble!

            beforeEach {
                combineLocationWithTimeTestDouble
                    = CombineLocationWithTimeTestDouble(result:
                        .failure(AppError.backendProblem(error: TestError.testError)))
                didScanMiddleware.combineLocationWithTime
                    = combineLocationWithTimeTestDouble
            }

            it("dispatches 'pending' when adding space URL") {
                let didScanAction = AppAction.zwaai(.didScan(url: url))
                var afterReducer: AfterReducer = .identity
                didScanMiddleware.handle(action: didScanAction,
                                         from: .here(), afterReducer: &afterReducer)

                expect(actionHandlerSpy.dispatchedActions) == [AppAction.zwaai(.checkinPending)]
            }

            it("sends a group element to the server") {
                let didScanAction = AppAction.zwaai(.didScan(url: url))
                var afterReducer: AfterReducer = .identity
                didScanMiddleware.handle(action: didScanAction,
                                         from: .here(), afterReducer: &afterReducer)

                expect(combineLocationWithTimeTestDouble.runCount).toEventually(equal(1))
            }

            it("dispatches checkinFailed when server request fails") {
                let didScanAction = AppAction.zwaai(.didScan(url: url))
                var afterReducer: AfterReducer = .identity
                didScanMiddleware.handle(action: didScanAction,
                                         from: .here(), afterReducer: &afterReducer)
                expect(actionHandlerSpy.dispatchedActions.count).toEventually(equal(2))
                expect(actionHandlerSpy.dispatchedActions[1].zwaai?.isCheckinFailed) == true
            }
        }

        context("given that server request succeeds") {
            beforeEach {
                let combineLocationWithTimeTestDouble
                    = CombineLocationWithTimeTestDouble(result:
                        .success([]))
                didScanMiddleware.combineLocationWithTime
                    = combineLocationWithTimeTestDouble
            }

            it("dispatches checkinSucceeded when server request succceeds") {
                let didScanAction = AppAction.zwaai(.didScan(url: url))
                var afterReducer: AfterReducer = .identity
                didScanMiddleware.handle(action: didScanAction,
                                         from: .here(), afterReducer: &afterReducer)
                expect(actionHandlerSpy.dispatchedActions.count).toEventually(equal(3))
                expect(actionHandlerSpy.dispatchedActions[1]) == .zwaai(.checkinSucceeded(space: space))
            }

            it("adds history item with time codes") {
                let timeCodes: [Scalar] = [.random(), .random(), .random()]
                let combineLocationWithTimeTestDouble
                    = CombineLocationWithTimeTestDouble(timeCodes: timeCodes)
                didScanMiddleware.combineLocationWithTime
                    = combineLocationWithTimeTestDouble

                let didScanAction = AppAction.zwaai(.didScan(url: url))
                var afterReducer: AfterReducer = .identity
                didScanMiddleware.handle(action: didScanAction,
                                         from: .here(), afterReducer: &afterReducer)
                expect(actionHandlerSpy.dispatchedActions.count).toEventually(equal(3))
                expect(actionHandlerSpy.dispatchedActions[2].history?.isAddItem) == true

                guard let addedSpace: CheckedInSpace =
                    actionHandlerSpy.dispatchedActions[2].history?.addItem?.type.space else {
                        fail("not a space")
                        return
                }
                timeCodes.enumerated().forEach { idx, timeCode in
                    expect(addedSpace.locationTimeCodes[idx] / timeCode) == space.locationCode
                }
            }
        }
    }
}

class ActionHandlerSpy: ActionHandler {
    typealias ActionType = AppAction

    var dispatchedActions = [AppAction]()

    func dispatch(_ action: AppAction, from dispatcher: ActionSource) {
        dispatchedActions.append(action)
    }
}

/// This test double can be configured in two ways:
/// 1. You can directly supply the result that the `run` operation should produce, or
/// 2. You can give an array of time codes that should be used to compute the resulting group elements.
class CombineLocationWithTimeTestDouble: CombineLocationWithTimeProto {
    let result: Result<[GroupElement], AppError>?
    let timeCodes: [Scalar]?
    var runCount = 0

    init(result: Result<[GroupElement], AppError>) {
        self.result = result
        self.timeCodes = nil
    }

    init(timeCodes: [Scalar]) {
        self.result = nil
        self.timeCodes = timeCodes
    }

    func run(encryptedLocation: GroupElement, completion: @escaping (Result<[GroupElement], AppError>) -> Void) {
        runCount += 1
        var result = self.result
        if result == nil {
            result = .success(computeAsServerWould(encryptedLcation: encryptedLocation))
        }
        DispatchQueue.main.async {
            completion(result!)
        }
    }

    func computeAsServerWould(encryptedLcation: GroupElement) -> [GroupElement] {
        guard let timeCodes = self.timeCodes else { fatalError("configuration error") }

        return timeCodes.map { $0 * encryptedLcation }
    }
}
