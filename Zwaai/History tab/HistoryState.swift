struct HistoryState {
    var lock: LockState
    var entries: [HistoryItem]
}

let initialHistoryState = HistoryState(
    lock: .unlocked,
    entries: []
)

enum LockState {
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
