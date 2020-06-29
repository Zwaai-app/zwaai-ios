import Foundation

public enum AppMetaAction {
    case didSaveState(result: Result<Date, AppError>)
}
