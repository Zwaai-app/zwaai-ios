import Foundation

public enum ZwaaiAction: Equatable, Prism {
    case didScan(url: ZwaaiURL)

    case checkin(space: CheckedInSpace)
    case checkout(space: CheckedInSpace)
}
