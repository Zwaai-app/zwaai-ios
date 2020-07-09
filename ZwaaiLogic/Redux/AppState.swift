import Foundation

public struct AppState: Codable, Equatable, CustomStringConvertible {
    public var history: HistoryState
    public var zwaai: ZwaaiState
    public var settings: SettingsState
    public var meta: AppMetaState = initialMetaState

    private enum CodingKeys: String, CodingKey {
        case history
        case zwaai
        case settings
    }

    public var description: String {
        return "{\n"
            + "      zwaai: \(zwaai)\n"
            + "    , history: \(history)\n"
            + "    , settings: \(settings)\n"
            + "    , meta: \(meta)"
            + "}"
    }
}

public let initialAppState = AppState(
    history: initialHistoryState,
    zwaai: initialZwaaiState,
    settings: initialSettingsState,
    meta: initialMetaState
)
