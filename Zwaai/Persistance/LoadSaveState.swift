import Foundation

func loadAppState() -> AppState? {
    if let file = stateFileUrl() {
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            return try decoder.decode(AppState.self, from: data)
        } catch let error {
            print("[error] Failed to load app state: ", error)
        }
    }

    return nil
}

func saveAppState(state: AppState) {
    let encoder = JSONEncoder()
    let out: Data
    do {
        out = try encoder.encode(state)
        guard let file = stateFileUrl() else { return }
        try out.write(to: file, options: [.atomic, .completeFileProtection])
    } catch let error {
        print("[error] Failed to encode state: ", error)
    }
}

// MARK: - Internals

private let stateFileName = "zwaai-state.json"

private func stateFileUrl() -> URL? {
    guard let docDir = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask).first else { return nil }

    return docDir.appendingPathComponent(stateFileName)
}
