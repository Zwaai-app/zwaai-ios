import Quick
import Nimble
@testable import ZwaaiLogic

class HistoryReducerSpec: QuickSpec {
    override func spec() {
        let space = CheckedInSpace(name: "test", description: "test", autoCheckout: nil)

        describe("lock") {
            let states = [
                historyState(lock: .unlocked),
                historyState(lock: .unlocking),
                historyState(lock: .locked)
            ]

            it("reduces .lock") {
                states.forEach {
                    expect(historyReducer.reduce(.lock, $0).lock) == .locked
                }
            }

            it("reduces .unlockFailed") {
                states.forEach {
                    expect(historyReducer.reduce(.unlockFailed, $0).lock) == .locked
                }
            }

            it("reduces .unlockSucceeded") {
                states.forEach {
                    expect(historyReducer.reduce(.unlockSucceeded, $0).lock) == .unlocked
                }
            }

            it("reduces .tryUnlock") {
                states.forEach {
                    expect(historyReducer.reduce(.tryUnlock, $0).lock) == .unlocking
                }
            }
        }

        it("ignores addEntry because that is done by middleware") {
            let state = historyState()
            let url = URL(string: "https://example.com")!
            expect(historyReducer.reduce(.addEntry(url: url), state)) == state
        }

        it("reduces addItem for person") {
            let item = HistoryItem(id: UUID(), timestamp: Date(), type: .person, random: Random())
            let state = historyReducer.reduce(.addItem(item: item), historyState())
            expect(state.entries).to(haveCount(1))
            expect(state.entries[0]) == item
            expect(state.allTimePersonZwaaiCount) == 1
            expect(state.allTimeSpaceZwaaiCount) == 0
        }

        it("reduces addItem for space") {
            let item = HistoryItem(id: UUID(), timestamp: Date(), type: .space(space: space), random: Random())
            let state = historyReducer.reduce(.addItem(item: item), historyState())
            expect(state.entries).to(haveCount(1))
            expect(state.entries[0]) == item
            expect(state.allTimePersonZwaaiCount) == 0
            expect(state.allTimeSpaceZwaaiCount) == 1
        }

        describe("setCheckedOut") {
            it("ignores if space not found") {
                expect(historyReducer.reduce(.setCheckedOut(space: space), historyState())) == historyState()
            }

            it("updates if space found") {
                let item = HistoryItem(id: UUID(), timestamp: Date(), type: .space(space: space), random: Random())
                let stateBefore = historyState(entries: [item])
                let stateAfter = historyReducer.reduce(.setCheckedOut(space: space), stateBefore)
                expect(stateAfter.entries).to(haveCount(1))
                expect(stateAfter.entries[0].id) == stateBefore.entries[0].id
                expect(stateAfter.entries[0].type.space?.id) == stateBefore.entries[0].type.space?.id
                expect(stateAfter.entries[0].type.space?.checkedOut).toNot(beNil())
                expect(abs(stateAfter.entries[0].type.space!.checkedOut!.timeIntervalSinceNow)) < 5
            }
        }
    }
}

func historyState(
    lock: LockState = .unlocked,
    entries: [HistoryItem] = [],
    allTimePersonZwaaiCount: UInt = 0,
    allTimeSpaceZwaaiCount: UInt = 0
) -> HistoryState {
    HistoryState(
        lock: lock,
        entries: entries,
        allTimePersonZwaaiCount: allTimePersonZwaaiCount,
        allTimeSpaceZwaaiCount: allTimeSpaceZwaaiCount)
}
