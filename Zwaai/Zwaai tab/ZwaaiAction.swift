import Foundation

// sourcery: Prism
enum ZwaaiAction {
    case checkin(space: CheckedInSpace)
    case checkout(space: CheckedInSpace)
}
