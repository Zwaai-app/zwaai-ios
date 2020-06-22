struct HistoryState: Codable, CustomStringConvertible {
    var lock: LockState
    var entries: [HistoryItem]
    var allTimePersonZwaaiCount: UInt
    var allTimeRoomZwaaiCount: UInt

    var description: String {
        let entriesString = entries.map { $0.description }.joined(separator: ",\n")
        return "{lock: \(lock), entries: [\n" + entriesString + "]"
    }
}

let initialHistoryState = HistoryState(
    lock: .unlocked,
    entries: [],
    allTimePersonZwaaiCount: 0,
    allTimeRoomZwaaiCount: 0
)

enum LockState: String, Codable {
    case locked
    case unlocking
    case unlocked

    mutating func toggle() {
        if self == .locked {
            self = .unlocking
        } else if self == .unlocked {
            self = .locked
        }
    }

    func actionString() -> String {
        switch self {
        case .locked: return "Toon"
        case .unlocked: return "Verberg"
        case .unlocking: return "..."
        }
    }

    func isOpen() -> Bool { return self == .unlocked }

    mutating func unlockSucceeded() {
        self = .unlocked
    }
}
