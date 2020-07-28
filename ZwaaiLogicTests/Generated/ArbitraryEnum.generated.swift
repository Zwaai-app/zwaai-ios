// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

import Foundation
import UIKit
import SwiftCheck
import ZwaaiLogic

extension AppAction: Arbitrary {
    public static var arbitrary: Gen<AppAction> {
        return .frequency([
            (1, HistoryAction.arbitrary.map { AppAction.history(($0)) }),
            (1, ZwaaiAction.arbitrary.map { AppAction.zwaai(($0)) }),
            (1, SettingsAction.arbitrary.map { AppAction.settings(($0)) }),
            (1, AppMetaAction.arbitrary.map { AppAction.meta(($0)) }),
            (1, .pure(AppAction.resetAppState))
        ])
    }
}

extension HistoryAction: Arbitrary {
    public static var arbitrary: Gen<HistoryAction> {
        return .frequency([
            (1, .pure(HistoryAction.lock)),
            (1, .pure(HistoryAction.tryUnlock)),
            (1, .pure(HistoryAction.unlockSucceeded)),
            (1, .pure(HistoryAction.unlockFailed)),
            (1, HistoryItem.arbitrary.map { HistoryAction.addItem(item: ($0)) }),
            (1, CheckedInSpace.arbitrary.map { HistoryAction.setCheckedOut(space: ($0)) }),
            (1, String.arbitrary.map { HistoryAction.prune(reason: ($0)) })
        ])
    }
}

extension NotificationPermission: Arbitrary {
    public static var arbitrary: Gen<NotificationPermission> {
        return .frequency([
            (1, .pure(NotificationPermission.undecided)),
            (1, .pure(NotificationPermission.allowed)),
            (1, .pure(NotificationPermission.denied))
        ])
    }
}

extension SettingsAction: Arbitrary {
    public static var arbitrary: Gen<SettingsAction> {
        return .frequency([
            (1, NotificationPermission.arbitrary.map { SettingsAction.set(notificationPermission: ($0)) })
        ])
    }
}

extension ZwaaiAction: Arbitrary {
    public static var arbitrary: Gen<ZwaaiAction> {
        return .frequency([
            (1, ZwaaiURL.arbitrary.map { ZwaaiAction.didScan(url: ($0)) }),
            (1, CheckedInSpace.arbitrary.map { ZwaaiAction.checkin(space: ($0)) }),
            (1, CheckedInSpace.arbitrary.map { ZwaaiAction.checkout(space: ($0)) })
        ])
    }
}
