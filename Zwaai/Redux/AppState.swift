import Foundation

struct AppState: Codable {
    var history: HistoryState
    var zwaai: ZwaaiState
    var meta: AppMetaState = AppMetaState()

    private enum CodingKeys: String, CodingKey {
        case history
        case zwaai
    }
}

let initialAppState = AppState(
    history: initialHistoryState,
    zwaai: initialZwaaiState
)
