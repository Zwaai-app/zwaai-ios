import Foundation

struct AppState: Codable {
    var history: HistoryState
    var meta: AppMetaState = AppMetaState()

    private enum CodingKeys: String, CodingKey {
        case history
    }
}

let initialAppState = AppState(history: initialHistoryState)
