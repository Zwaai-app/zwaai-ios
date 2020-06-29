// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension AppAction {
    public var history: HistoryAction? {
        get {
            guard case let .history(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .history = self, let newValue = newValue else { return }
            self = .history(newValue)
        }
    }

    public var isHistory: Bool {
        self.history != nil
    }

    public var zwaai: ZwaaiAction? {
        get {
            guard case let .zwaai(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .zwaai = self, let newValue = newValue else { return }
            self = .zwaai(newValue)
        }
    }

    public var isZwaai: Bool {
        self.zwaai != nil
    }

    public var meta: AppMetaAction? {
        get {
            guard case let .meta(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .meta = self, let newValue = newValue else { return }
            self = .meta(newValue)
        }
    }

    public var isMeta: Bool {
        self.meta != nil
    }

    public var resetAppState: Void? {
        guard case .resetAppState = self else { return nil }
        return ()
    }

    public var isResetAppState: Bool {
        self.resetAppState != nil
    }

}
extension HistoryZwaaiType {
    public var person: Void? {
        guard case .person = self else { return nil }
        return ()
    }

    public var isPerson: Bool {
        self.person != nil
    }

    public var space: CheckedInSpace? {
        get {
            guard case let .space(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .space = self, let newValue = newValue else { return }
            self = .space(space: newValue)
        }
    }

    public var isSpace: Bool {
        self.space != nil
    }

}
extension ZwaaiAction {
    public var checkin: CheckedInSpace? {
        get {
            guard case let .checkin(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .checkin = self, let newValue = newValue else { return }
            self = .checkin(space: newValue)
        }
    }

    public var isCheckin: Bool {
        self.checkin != nil
    }

    public var checkout: CheckedInSpace? {
        get {
            guard case let .checkout(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .checkout = self, let newValue = newValue else { return }
            self = .checkout(space: newValue)
        }
    }

    public var isCheckout: Bool {
        self.checkout != nil
    }

}
