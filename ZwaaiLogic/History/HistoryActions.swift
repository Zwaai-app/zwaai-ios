import Foundation

public enum HistoryAction: Equatable {
    case lock
    case tryUnlock
    case unlockSucceeded
    case unlockFailed

    case addEntry(url: URL)
    case addItem(item: HistoryItem)

    case setCheckedOut(space: CheckedInSpace)
}
