import Foundation

enum AppMetaAction {
    case didSaveState(result: Result<Date, AppError>)
}
