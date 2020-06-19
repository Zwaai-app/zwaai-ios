enum AppAction {
    case history(HistoryAction)
}

extension AppAction {
    public var history: HistoryAction? {
        get {
            guard case let .history(value) = self else { return nil }
            return value
        }
        set {
            guard case .history = self, let newValue = newValue else { return }
            self = .history(newValue)
        }
    }
    case zwaai(ZwaaiAction)
}
