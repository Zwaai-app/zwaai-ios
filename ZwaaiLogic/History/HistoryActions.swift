import Foundation

public enum HistoryAction: Equatable, Prism {
    case lock
    case tryUnlock
    case unlockSucceeded
    case unlockFailed

    case addItem(item: HistoryItem)

    case setCheckedOut(space: CheckedInSpace)

    case prune(reason: String)
}
