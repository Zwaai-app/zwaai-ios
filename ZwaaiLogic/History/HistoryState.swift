public struct HistoryState: Equatable, Codable, CustomStringConvertible {
    public var lock: LockState
    public var entries: [HistoryItem]
    public var allTimePersonZwaaiCount: UInt
    public var allTimeSpaceZwaaiCount: UInt

    public var description: String {
        let entriesString = entries.map { $0.description }.joined(separator: ",\n")
        return "{lock: \(lock), entries: [\n" + entriesString + "]"
    }
}

let initialHistoryState = HistoryState(
    lock: .unlocked,
    entries: [],
    allTimePersonZwaaiCount: 0,
    allTimeSpaceZwaaiCount: 0
)

public enum LockState: String, Codable {
    case locked
    case unlocking
    case unlocked

    public mutating func toggle() {
        if self == .locked {
            self = .unlocking
        } else if self == .unlocked {
            self = .locked
        }
    }

    public func actionString() -> String {
        switch self {
        case .locked: return "Toon"
        case .unlocked: return "Verberg"
        case .unlocking: return "..."
        }
    }

    public func isOpen() -> Bool { return self == .unlocked }

    mutating func unlockSucceeded() {
        self = .unlocked
    }
}
