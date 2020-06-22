import Foundation

struct AppState: Codable {
    var history: HistoryState
}

let initialAppState: AppState = {
    return loadAppState() ?? AppState(history: initialHistoryState)
}()
