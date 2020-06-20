import Foundation

enum HistoryAction {
    case lock
    case tryUnlock
    case unlockSucceeded
    case unlockFailed

    case addEntry(url: URL)
}
