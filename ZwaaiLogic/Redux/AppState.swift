import Foundation

public struct AppState: Codable, Equatable {
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
