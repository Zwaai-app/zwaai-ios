import Foundation

public enum AppMetaAction: Equatable {
    case didSaveState(result: Result<Date, AppError>)
}
