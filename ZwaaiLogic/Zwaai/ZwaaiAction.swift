import Foundation

public enum ZwaaiAction: Equatable, Prism {
    case didScan(url: ZwaaiURL)

    case checkinPending
    case checkinSucceeded(space: CheckedInSpace)
    case checkinFailed(reason: String)

    case checkout(space: CheckedInSpace)
}
