import Foundation

struct AppState: Codable {
    var history: HistoryState
}

let initialAppState = AppState(
    history: initialHistoryState
)
