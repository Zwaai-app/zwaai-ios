import Foundation

// sourcery: Prism
public enum AppMetaAction: Equatable {
    case didSaveState(result: Result<Date, AppError>)
}
