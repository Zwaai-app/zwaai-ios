import Foundation

func loadAppState() -> Result<AppState, AppError> {
    stateFileUrl().flatMap { url in
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .success(initialAppState)
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return .success(try decoder.decode(AppState.self, from: data))
        } catch let error {
            return .failure(.decodeStateFailure(error: error))
        }
    }
}

func saveAppState(state: AppState) -> Result<Date, AppError> {
    stateFileUrl().flatMap { url in
        let encoder = JSONEncoder()
        let out: Data
        do {
            out = try encoder.encode(state)
            try out.write(to: url, options: [.atomic, .completeFileProtection])
            return .success(Date())
        } catch let error {
            return .failure(.encodeStateFailure(error: error))
        }
    }
}

// MARK: - Internals

private let stateFileName = "zwaai-state.json"

private func stateFileUrl() -> Result<URL, AppError> {
    guard let docDir = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask).first else {
            return .failure(.noUserDocumentsDirectory)
    }

    return .success(docDir.appendingPathComponent(stateFileName))
}
