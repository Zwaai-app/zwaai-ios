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

func historyState(
    lock: LockState = .unlocked,
    entries: [HistoryItem] = [],
    allTimePersonZwaaiCount: UInt = 0,
    allTimeSpaceZwaaiCount: UInt = 0,
    pruneLog: [PruneEvent] = []
) -> HistoryState {
    HistoryState(
        lock: lock,
        entries: entries,
        allTimePersonZwaaiCount: allTimePersonZwaaiCount,
        allTimeSpaceZwaaiCount: allTimeSpaceZwaaiCount,
        pruneLog: pruneLog)
}
