// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension AppAction {
    internal var history: HistoryAction? {
        get {
            guard case let .history(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .history = self, let newValue = newValue else { return }
            self = .history(newValue)
        }
    }

    internal var isHistory: Bool {
        self.history != nil
    }

    internal var zwaai: ZwaaiAction? {
        get {
            guard case let .zwaai(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .zwaai = self, let newValue = newValue else { return }
            self = .zwaai(newValue)
        }
    }

    internal var isZwaai: Bool {
        self.zwaai != nil
    }

    internal var meta: AppMetaAction? {
        get {
            guard case let .meta(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .meta = self, let newValue = newValue else { return }
            self = .meta(newValue)
        }
    }

    internal var isMeta: Bool {
        self.meta != nil
    }

}
