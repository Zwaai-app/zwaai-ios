import Foundation
import SwiftRex

public class DidScanURLMiddleware: Middleware {
    public typealias InputActionType = AppAction
    public typealias OutputActionType = AppAction
    public typealias StateType = Void

    var output: AnyActionHandler<AppAction>?
    var combineLocationWithTime: CombineLocationWithTimeProto = CombineLocationWithTime()

    public func receiveContext(getState: @escaping GetState<Void>, output: AnyActionHandler<AppAction>) {
        self.output = output
    }

    public func handle(action: AppAction, from dispatcher: ActionSource, afterReducer: inout AfterReducer) {
        if let url = action.zwaai?.didScan {
            switch url.type {
            case .person:
                let item = HistoryItem(
                    id: UUID(),
                    timestamp: Date(),
                    type: url.type)
                self.output?.dispatch(.history(.addItem(item: item)))
            case .space(let space):
                self.output?.dispatch(.zwaai(.checkinPending))
                let random = Scalar.random()
                let encryptedLocation = random * space.locationCode
                combineLocationWithTime.run(encryptedLocation: encryptedLocation) { result in
                    switch result {
                    case .failure(let error):
                        print("[error] Server error: ", error)
                        self.output?.dispatch(.zwaai(.checkinFailed(reason: "Server error")))
                    case .success(let encryptedLocationTimeCodes):
                        self.output?.dispatch(.zwaai(.checkinSucceeded(space: space)))
                        let locationTimeCodes = encryptedLocationTimeCodes.map { $0 / random }
                        let checkedInSpace = CheckedInSpace(
                            name: space.name,
                            locationCode: space.locationCode,
                            description: space.description,
                            autoCheckout: space.autoCheckout,
                            deadline: space.deadline,
                            locationTimeCodes: locationTimeCodes)
                        let item = HistoryItem(
                            id: UUID(),
                            timestamp: Date(),
                            type: .space(space: checkedInSpace))
                        self.output?.dispatch(.history(.addItem(item: item)))
                    }
                }
            }
        } else if let item = action.history?.addItem {
            if case let .space(space) = item.type {
                self.output?.dispatch(.zwaai(.checkin(space: space)))
            }
        }
    }
}
