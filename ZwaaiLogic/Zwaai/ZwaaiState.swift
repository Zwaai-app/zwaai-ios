import Foundation

public struct ZwaaiState: Codable, CustomStringConvertible, Equatable {
    public var checkedIn: CheckedInSpace?

    public var description: String {
        guard let space = checkedIn else {
            return "not checked in"
        }
        return "Checked in: \(space)"
    }
}

let initialZwaaiState = ZwaaiState(checkedIn: nil)
