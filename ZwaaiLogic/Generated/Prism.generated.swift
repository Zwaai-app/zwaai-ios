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
extension AppError {
    public var noUserDocumentsDirectory: Void? {
        guard case .noUserDocumentsDirectory = self else { return nil }
        return ()
    }

    public var isNoUserDocumentsDirectory: Bool {
        self.noUserDocumentsDirectory != nil
    }

    public var decodeStateFailure: Error? {
        get {
            guard case let .decodeStateFailure(error) = self else { return nil }
            return (error)
        }
        set {
            guard case .decodeStateFailure = self, let newValue = newValue else { return }
            self = .decodeStateFailure(error: newValue)
        }
    }

    public var isDecodeStateFailure: Bool {
        self.decodeStateFailure != nil
    }

    public var encodeStateFailure: Error? {
        get {
            guard case let .encodeStateFailure(error) = self else { return nil }
            return (error)
        }
        set {
            guard case .encodeStateFailure = self, let newValue = newValue else { return }
            self = .encodeStateFailure(error: newValue)
        }
    }

    public var isEncodeStateFailure: Bool {
        self.encodeStateFailure != nil
    }

    public var invalidZwaaiType: String? {
        get {
            guard case let .invalidZwaaiType(type) = self else { return nil }
            return (type)
        }
        set {
            guard case .invalidZwaaiType = self, let newValue = newValue else { return }
            self = .invalidZwaaiType(type: newValue)
        }
    }

    public var isInvalidZwaaiType: Bool {
        self.invalidZwaaiType != nil
    }

}
extension AppMetaAction {
    public var didSaveState: Result<Date, AppError>? {
        get {
            guard case let .didSaveState(result) = self else { return nil }
            return (result)
        }
        set {
            guard case .didSaveState = self, let newValue = newValue else { return }
            self = .didSaveState(result: newValue)
        }
    }

    public var isDidSaveState: Bool {
        self.didSaveState != nil
    }

}
extension HistoryAction {
    public var lock: Void? {
        guard case .lock = self else { return nil }
        return ()
    }

    public var isLock: Bool {
        self.lock != nil
    }

    public var tryUnlock: Void? {
        guard case .tryUnlock = self else { return nil }
        return ()
    }

    public var isTryUnlock: Bool {
        self.tryUnlock != nil
    }

    public var unlockSucceeded: Void? {
        guard case .unlockSucceeded = self else { return nil }
        return ()
    }

    public var isUnlockSucceeded: Bool {
        self.unlockSucceeded != nil
    }

    public var unlockFailed: Void? {
        guard case .unlockFailed = self else { return nil }
        return ()
    }

    public var isUnlockFailed: Bool {
        self.unlockFailed != nil
    }

    public var addEntry: URL? {
        get {
            guard case let .addEntry(url) = self else { return nil }
            return (url)
        }
        set {
            guard case .addEntry = self, let newValue = newValue else { return }
            self = .addEntry(url: newValue)
        }
    }

    public var isAddEntry: Bool {
        self.addEntry != nil
    }

    public var addItem: HistoryItem? {
        get {
            guard case let .addItem(item) = self else { return nil }
            return (item)
        }
        set {
            guard case .addItem = self, let newValue = newValue else { return }
            self = .addItem(item: newValue)
        }
    }

    public var isAddItem: Bool {
        self.addItem != nil
    }

    public var setCheckedOut: CheckedInSpace? {
        get {
            guard case let .setCheckedOut(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .setCheckedOut = self, let newValue = newValue else { return }
            self = .setCheckedOut(space: newValue)
        }
    }

    public var isSetCheckedOut: Bool {
        self.setCheckedOut != nil
    }

    public var prune: String? {
        get {
            guard case let .prune(reason) = self else { return nil }
            return (reason)
        }
        set {
            guard case .prune = self, let newValue = newValue else { return }
            self = .prune(reason: newValue)
        }
    }

    public var isPrune: Bool {
        self.prune != nil
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
extension ZwaaiType {
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
