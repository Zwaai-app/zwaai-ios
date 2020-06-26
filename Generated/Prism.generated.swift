// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
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

    internal var resetAppState: Void? {
        get {
            guard case .resetAppState = self else { return nil }
            return ()
        }
    }

    internal var isResetAppState: Bool {
        self.resetAppState != nil
    }

}
extension HistoryZwaaiType {
    internal var person: Void? {
        get {
            guard case .person = self else { return nil }
            return ()
        }
    }

    internal var isPerson: Bool {
        self.person != nil
    }

    internal var space: CheckedInSpace? {
        get {
            guard case let .space(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .space = self, let newValue = newValue else { return }
            self = .space(space: newValue)
        }
    }

    internal var isSpace: Bool {
        self.space != nil
    }

}
extension ZwaaiAction {
    internal var checkin: CheckedInSpace? {
        get {
            guard case let .checkin(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .checkin = self, let newValue = newValue else { return }
            self = .checkin(space: newValue)
        }
    }

    internal var isCheckin: Bool {
        self.checkin != nil
    }

    internal var checkout: Void? {
        get {
            guard case .checkout = self else { return nil }
            return ()
        }
    }

    internal var isCheckout: Bool {
        self.checkout != nil
    }

}
