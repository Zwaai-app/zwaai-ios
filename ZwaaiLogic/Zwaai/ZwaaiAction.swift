import Foundation

// sourcery: Prism
public enum ZwaaiAction {
    case checkin(space: CheckedInSpace)
    case checkout(space: CheckedInSpace)
}
