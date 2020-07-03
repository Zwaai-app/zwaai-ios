public struct HistoryState: Equatable, Codable, CustomStringConvertible {
    public var lock: LockState
    public var entries: [HistoryItem]
    public var allTimePersonZwaaiCount: UInt
    public var allTimeSpaceZwaaiCount: UInt
    #if DEBUG
    public var pruneLog: [PruneEvent]
    #endif

    public var description: String {
        let entriesString = entries.map { $0.description }.joined(separator: ",\n")
        #if DEBUG
        let pruneDescription = "[" + pruneLog.map { $0.description }.joined(separator: ",\n") + "]"
        #else
        let pruneDescription = ""
        #endif
        return "{lock: \(lock), entries: [\n" + entriesString + "]" + pruneDescription + "}"
    }
}

#if DEBUG
let initialHistoryState = HistoryState(
    lock: .unlocked,
    entries: [],
    allTimePersonZwaaiCount: 0,
    allTimeSpaceZwaaiCount: 0,
    pruneLog: []
)
#else
let initialHistoryState = HistoryState(
    lock: .unlocked,
    entries: [],
    allTimePersonZwaaiCount: 0,
    allTimeSpaceZwaaiCount: 0
)
#endif

public enum LockState: String, Codable {
    case locked
    case unlocking
    case unlocked

    public func actionString() -> String {
        switch self {
        case .locked: return "Toon"
        case .unlocked: return "Verberg"
        case .unlocking: return "..."
        }
    }

    public func isOpen() -> Bool { return self == .unlocked }
}

#if DEBUG
public struct PruneEvent: Equatable, Codable, CustomStringConvertible {
    public var timestamp: Date
    public var numEntriesRemoved: UInt

    public init(numEntriesRemoved: UInt) {
        self.numEntriesRemoved = numEntriesRemoved
        self.timestamp = Date()
    }

    public var description: String {
        return "{timestamp: \(DateFormatter.shortNL.string(from: timestamp))"
            + ", numEntriesRemoved: \(numEntriesRemoved)"
            + "}"
    }
}
#endif
