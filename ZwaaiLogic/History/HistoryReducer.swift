import Foundation
import SwiftRex

let maxHistoryEntryAge = TimeInterval(14*24*3600)

let historyReducer = Reducer<HistoryAction, HistoryState> { action, state in
    var newState = state
    switch action {
    case .lock:
        newState.lock = .locked
    case .unlockFailed:
        newState.lock = .locked
    case .unlockSucceeded:
        newState.lock = .unlocked
    case .tryUnlock:
        newState.lock = .unlocking

    case .addEntry(let url): break

    case .addItem(let item):
        switch item.type {
        case .person: newState.allTimePersonZwaaiCount += 1
        case .space: newState.allTimeSpaceZwaaiCount += 1
        }
        newState.entries.insert(item, at: 0)

    case .setCheckedOut(let space):
        if let index = newState.entries.firstIndex(where: { $0.type.isSpace && $0.type.space?.id == space.id }),
            var updatedSpace = newState.entries[index].type.space {
            updatedSpace.checkedOut = Date()
            newState.entries[index].type = .space(space: updatedSpace)
        }
    case .prune:
        newState.entries = newState.entries.filter {
            $0.timestamp.timeIntervalSinceNow <= 0 &&
            $0.timestamp.timeIntervalSinceNow > -maxHistoryEntryAge
        }
        #if DEBUG
        let numRemoved = state.entries.count - newState.entries.count
        newState.pruneLog.append(PruneEvent(numEntriesRemoved: UInt(numRemoved)))
        #endif
    }
    return newState
}
