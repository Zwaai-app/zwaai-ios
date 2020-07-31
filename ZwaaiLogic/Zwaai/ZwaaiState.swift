import Foundation

public struct ZwaaiState: Codable, CustomStringConvertible, Equatable {
    public var checkedInStatus: ActionStatus<CheckedInSpace>?

    public var description: String {
        guard let status = checkedInStatus else {
            return "not checked in"
        }
        return "Checked in: \(status)"
    }
}

let initialZwaaiState = ZwaaiState(checkedInStatus: nil)
