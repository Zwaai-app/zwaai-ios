import Foundation

public enum ZwaaiAction: Equatable, Prism {
    case checkin(space: CheckedInSpace)
    case checkout(space: CheckedInSpace)
}
