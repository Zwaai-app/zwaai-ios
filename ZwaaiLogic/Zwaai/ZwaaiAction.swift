import Foundation

// sourcery: Prism
public enum ZwaaiAction: Equatable {
    case checkin(space: CheckedInSpace)
    case checkout(space: CheckedInSpace)
}
