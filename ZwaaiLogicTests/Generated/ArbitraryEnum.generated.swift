// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import SwiftCheck
import ZwaaiLogic

extension AppAction: Arbitrary {
    public static var arbitrary: Gen<AppAction> {
        return .frequency([
            (1, HistoryAction.arbitrary.map { AppAction.history(($0)) }),
            (1, ZwaaiAction.arbitrary.map { AppAction.zwaai(($0)) }),
            (1, AppMetaAction.arbitrary.map { AppAction.meta(($0)) }),
            (1, .pure(AppAction.resetAppState))
        ])
    }
}
extension AppMetaAction: Arbitrary {
    public static var arbitrary: Gen<AppMetaAction> {
        return .frequency([
            (1, Result<Date, AppError>.arbitrary.map { AppMetaAction.didSaveState(result: ($0)) })
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
            (1, URL.arbitrary.map { HistoryAction.addEntry(url: ($0)) }),
            (1, HistoryItem.arbitrary.map { HistoryAction.addItem(item: ($0)) }),
            (1, CheckedInSpace.arbitrary.map { HistoryAction.setCheckedOut(space: ($0)) })
        ])
    }
}
extension ZwaaiAction: Arbitrary {
    public static var arbitrary: Gen<ZwaaiAction> {
        return .frequency([
            (1, CheckedInSpace.arbitrary.map { ZwaaiAction.checkin(space: ($0)) }),
            (1, CheckedInSpace.arbitrary.map { ZwaaiAction.checkout(space: ($0)) })
        ])
    }
}
