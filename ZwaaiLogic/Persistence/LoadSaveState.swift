import Foundation

public func loadAppState() -> Result<AppState, AppError> {
    return loadAppState(deps: .default)
}

func loadAppState(deps: LoadSaveDeps) -> Result<AppState, AppError> {
    stateFileUrl(deps: deps).flatMap { url in
        guard deps.fileManager.fileExists(atPath: url.path) else {
            return .success(initialAppState)
        }

        do {
            let data = try deps.loadContentsOf(url)
            let decoder = JSONDecoder()
            return .success(try decoder.decode(AppState.self, from: data))
        } catch let error {
            return .failure(.decodeStateFailure(error: error))
        }
    }
}

public func saveAppState(state: AppState) -> Result<Date, AppError> {
    return saveAppState(state: state, deps: .default)
}

func saveAppState(state: AppState, deps: LoadSaveDeps) -> Result<Date, AppError> {
    stateFileUrl(deps: deps).flatMap { url in
        let encoder = JSONEncoder()
        let out: Data
        do {
            out = try encoder.encode(state)
            try deps.writeData(out, url, [.atomic, .completeFileProtection])
            return .success(Date())
        } catch let error {
            return .failure(.encodeStateFailure(error: error))
        }
    }
}

// MARK: - Internals

let stateFileName = "zwaai-state.json"

private func stateFileUrl(deps: LoadSaveDeps) -> Result<URL, AppError> {
    guard let docDir = deps.fileManager.urls(
        for: .documentDirectory,
        in: .userDomainMask).first else {
            return .failure(.noUserDocumentsDirectory)
    }

    return .success(docDir.appendingPathComponent(stateFileName))
}

class LoadSaveDeps {
    typealias DataReader = (URL) throws -> Data
    typealias DataWriter = (Data, URL, Data.WritingOptions) throws -> Void

    var fileManager: FileManagerProto = FileManager.default
    var loadContentsOf: DataReader = { url in
        return try Data(contentsOf: url)
    }
    var writeData: DataWriter = { data, url, options in
        try data.write(to: url, options: options)
    }

    static var `default` = LoadSaveDeps()
}
