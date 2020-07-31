// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

import Foundation
import UIKit
import SwiftCheck
import ZwaaiLogic

extension ActionStatus {

    public var pending: Void? {
        guard case .pending = self else { return nil }
        return ()
    }

    public var isPending: Bool {
        self.pending != nil
    }

    public var succeeded: SuccessValue? {
        get {
            guard case let .succeeded(value) = self else { return nil }
            return (value)
        }
        set {
            guard case .succeeded = self, let newValue = newValue else { return }
            self = .succeeded(value: newValue)
        }
    }

    public var isSucceeded: Bool {
        self.succeeded != nil
    }

    public var failed: String? {
        get {
            guard case let .failed(reason) = self else { return nil }
            return (reason)
        }
        set {
            guard case .failed = self, let newValue = newValue else { return }
            self = .failed(reason: newValue)
        }
    }

    public var isFailed: Bool {
        self.failed != nil
    }

}

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

    public var settings: SettingsAction? {
        get {
            guard case let .settings(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .settings = self, let newValue = newValue else { return }
            self = .settings(newValue)
        }
    }

    public var isSettings: Bool {
        self.settings != nil
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

    public var decodeFailure: Error?? {
        get {
            guard case let .decodeFailure(error) = self else { return nil }
            return (error)
        }
        set {
            guard case .decodeFailure = self, let newValue = newValue else { return }
            self = .decodeFailure(error: newValue)
        }
    }

    public var isDecodeFailure: Bool {
        self.decodeFailure != nil
    }

    public var encodeFailure: Error?? {
        get {
            guard case let .encodeFailure(error) = self else { return nil }
            return (error)
        }
        set {
            guard case .encodeFailure = self, let newValue = newValue else { return }
            self = .encodeFailure(error: newValue)
        }
    }

    public var isEncodeFailure: Bool {
        self.encodeFailure != nil
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

    public var backendProblem: Error?? {
        get {
            guard case let .backendProblem(error) = self else { return nil }
            return (error)
        }
        set {
            guard case .backendProblem = self, let newValue = newValue else { return }
            self = .backendProblem(error: newValue)
        }
    }

    public var isBackendProblem: Bool {
        self.backendProblem != nil
    }

    public var backendResponseError: Int? {
        get {
            guard case let .backendResponseError(statusCode) = self else { return nil }
            return (statusCode)
        }
        set {
            guard case .backendResponseError = self, let newValue = newValue else { return }
            self = .backendResponseError(statusCode: newValue)
        }
    }

    public var isBackendResponseError: Bool {
        self.backendResponseError != nil
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

    public var zwaaiSucceeded: (url: ZwaaiURL, presentingController: UIViewController, onDismiss: () -> Void)? {
        get {
            guard case let .zwaaiSucceeded(url, presentingController, onDismiss) = self else { return nil }
            return (url, presentingController, onDismiss)
        }
        set {
            guard case .zwaaiSucceeded = self, let newValue = newValue else { return }
            self = .zwaaiSucceeded(url: newValue.0, presentingController: newValue.1, onDismiss: newValue.2)
        }
    }

    public var isZwaaiSucceeded: Bool {
        self.zwaaiSucceeded != nil
    }

    public var zwaaiFailed: (presentingController: UIViewController, onDismiss: () -> Void)? {
        get {
            guard case let .zwaaiFailed(presentingController, onDismiss) = self else { return nil }
            return (presentingController, onDismiss)
        }
        set {
            guard case .zwaaiFailed = self, let newValue = newValue else { return }
            self = .zwaaiFailed(presentingController: newValue.0, onDismiss: newValue.1)
        }
    }

    public var isZwaaiFailed: Bool {
        self.zwaaiFailed != nil
    }

    public var setupAutoCheckout: Void? {
        guard case .setupAutoCheckout = self else { return nil }
        return ()
    }

    public var isSetupAutoCheckout: Bool {
        self.setupAutoCheckout != nil
    }

    public var notification: NotificationAction? {
        get {
            guard case let .notification(action) = self else { return nil }
            return (action)
        }
        set {
            guard case .notification = self, let newValue = newValue else { return }
            self = .notification(action: newValue)
        }
    }

    public var isNotification: Bool {
        self.notification != nil
    }

    public var setFeedbackContinuation: FeedbackContinuation? {
        get {
            guard case let .setFeedbackContinuation(continuation) = self else { return nil }
            return (continuation)
        }
        set {
            guard case .setFeedbackContinuation = self, let newValue = newValue else { return }
            self = .setFeedbackContinuation(continuation: newValue)
        }
    }

    public var isSetFeedbackContinuation: Bool {
        self.setFeedbackContinuation != nil
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

extension NotificationAction {

    public var checkSystemPermissions: Void? {
        guard case .checkSystemPermissions = self else { return nil }
        return ()
    }

    public var isCheckSystemPermissions: Bool {
        self.checkSystemPermissions != nil
    }

    public var set: UNAuthorizationStatus? {
        get {
            guard case let .set(systemPermission) = self else { return nil }
            return (systemPermission)
        }
        set {
            guard case .set = self, let newValue = newValue else { return }
            self = .set(systemPermission: newValue)
        }
    }

    public var isSet: Bool {
        self.set != nil
    }

    public var getPending: Void? {
        guard case .getPending = self else { return nil }
        return ()
    }

    public var isGetPending: Bool {
        self.getPending != nil
    }

    public var setPending: [UNNotificationRequest]? {
        get {
            guard case let .setPending(requests) = self else { return nil }
            return (requests)
        }
        set {
            guard case .setPending = self, let newValue = newValue else { return }
            self = .setPending(requests: newValue)
        }
    }

    public var isSetPending: Bool {
        self.setPending != nil
    }

    public var removePending: UUID? {
        get {
            guard case let .removePending(requestId) = self else { return nil }
            return (requestId)
        }
        set {
            guard case .removePending = self, let newValue = newValue else { return }
            self = .removePending(requestId: newValue)
        }
    }

    public var isRemovePending: Bool {
        self.removePending != nil
    }

}

extension SettingsAction {

    public var set: NotificationPermission? {
        get {
            guard case let .set(notificationPermission) = self else { return nil }
            return (notificationPermission)
        }
        set {
            guard case .set = self, let newValue = newValue else { return }
            self = .set(notificationPermission: newValue)
        }
    }

    public var isSet: Bool {
        self.set != nil
    }

}

extension ZwaaiAction {

    public var didScan: ZwaaiURL? {
        get {
            guard case let .didScan(url) = self else { return nil }
            return (url)
        }
        set {
            guard case .didScan = self, let newValue = newValue else { return }
            self = .didScan(url: newValue)
        }
    }

    public var isDidScan: Bool {
        self.didScan != nil
    }

    public var checkinPending: Void? {
        guard case .checkinPending = self else { return nil }
        return ()
    }

    public var isCheckinPending: Bool {
        self.checkinPending != nil
    }

    public var checkinSucceeded: CheckedInSpace? {
        get {
            guard case let .checkinSucceeded(space) = self else { return nil }
            return (space)
        }
        set {
            guard case .checkinSucceeded = self, let newValue = newValue else { return }
            self = .checkinSucceeded(space: newValue)
        }
    }

    public var isCheckinSucceeded: Bool {
        self.checkinSucceeded != nil
    }

    public var checkinFailed: String? {
        get {
            guard case let .checkinFailed(reason) = self else { return nil }
            return (reason)
        }
        set {
            guard case .checkinFailed = self, let newValue = newValue else { return }
            self = .checkinFailed(reason: newValue)
        }
    }

    public var isCheckinFailed: Bool {
        self.checkinFailed != nil
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

    public var person: Random? {
        get {
            guard case let .person(random) = self else { return nil }
            return (random)
        }
        set {
            guard case .person = self, let newValue = newValue else { return }
            self = .person(random: newValue)
        }
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
