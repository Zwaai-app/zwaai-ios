import Foundation

public struct ZwaaiState: Codable, CustomStringConvertible, Equatable {
    public var checkedIn: CheckedInSpace?

    public var description: String {
        if let space = checkedIn {
            return "Checked in: \(space)"
        } else {
            return "not checked in"
        }
    }
}

let initialZwaaiState = ZwaaiState(checkedIn: nil)
