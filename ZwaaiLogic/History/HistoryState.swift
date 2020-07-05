public struct HistoryState: Equatable, Codable, CustomStringConvertible {
    public var lock: LockState
    public var entries: [HistoryItem]
    public var allTimePersonZwaaiCount: UInt
    public var allTimeSpaceZwaaiCount: UInt
    #if DEV_MODE
    public var pruneLog: [PruneEvent]
    #endif

    public var description: String {
        let entriesString = entries.map { $0.description }.joined(separator: ",\n")
        #if DEV_MODE
        let pruneDescription = "[" + pruneLog.map { $0.description }.joined(separator: ",\n") + "]"
        #else
        let pruneDescription = ""
        #endif
        return "{lock: \(lock), entries: [\n" + entriesString + "]" + pruneDescription + "}"
    }
}

#if DEV_MODE
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

public struct PruneEvent: Equatable, Codable, CustomStringConvertible {
#if DEV_MODE
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
