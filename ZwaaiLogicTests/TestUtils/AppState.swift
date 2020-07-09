import Foundation
@testable import ZwaaiLogic

func appState(
    history: HistoryState = initialHistoryState,
    zwaai: ZwaaiState = initialZwaaiState,
    settings: SettingsState = initialSettingsState,
    meta: AppMetaState = initialMetaState
) -> AppState {
    return AppState(history: history, zwaai: zwaai, settings: settings, meta: meta)
}
