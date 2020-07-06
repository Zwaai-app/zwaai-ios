import Foundation

// sourcery: Prism
public enum HistoryAction: Equatable {
    case lock
    case tryUnlock
    case unlockSucceeded
    case unlockFailed

    case addEntry(url: ZwaaiURL)
    case addItem(item: HistoryItem)

    case setCheckedOut(space: CheckedInSpace)

    case prune(reason: String)
}
