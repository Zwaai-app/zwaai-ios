import Foundation

struct AppState: Codable {
    var history: HistoryState
}

let initialAppState: AppState = {
    if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let file = docDir.appendingPathComponent("zwaai-state.json")
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            return try decoder.decode(AppState.self, from: data)
        } catch (let e) {
            print("[error] Failed to load app state: ", e)
        }
    }

    return AppState(history: initialHistoryState)
}()
