import Foundation

public struct AppState: Codable {
    public var history: HistoryState
    public var zwaai: ZwaaiState
    public var meta: AppMetaState = AppMetaState()

    private enum CodingKeys: String, CodingKey {
        case history
        case zwaai
    }
}

public let initialAppState = AppState(
    history: initialHistoryState,
    zwaai: initialZwaaiState
)
