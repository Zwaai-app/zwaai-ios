import Foundation

public enum ZwaaiAction: Equatable, Prism {
    case didScan(url: ZwaaiURL)

    case checkinPending
    case checkinSucceeded(space: CheckedInSpace)
    case checkinFailed(reason: String)

    case checkin(space: CheckedInSpace) // TODO: remove in favor of checkinSucceeded
    case checkout(space: CheckedInSpace)
}
