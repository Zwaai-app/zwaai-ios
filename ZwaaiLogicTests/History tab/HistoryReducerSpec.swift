import Quick
import Nimble
import SwiftCheck
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
            let url = ZwaaiURL(from: validPersonURL)!
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

            it("takes deadline if auto-checkout should already have been done") {
                let space2 = CheckedInSpace(
                    name: "test",
                    description: "test",
                    autoCheckout: 1800,
                    deadline: Date(timeIntervalSinceNow: -300))
                let item = HistoryItem(id: UUID(), timestamp: Date(), type: .space(space: space2), random: Random())
                let stateBefore = historyState(entries: [item])
                let stateAfter = historyReducer.reduce(.setCheckedOut(space: space2), stateBefore)
                expect(stateAfter.entries).to(haveCount(1))
                expect(stateAfter.entries[0].id) == stateBefore.entries[0].id
                expect(stateAfter.entries[0].type.space?.id) == stateBefore.entries[0].type.space?.id
                expect(stateAfter.entries[0].type.space?.checkedOut).toNot(beNil())
                expect(abs(stateAfter.entries[0].type.space!.checkedOut!.timeIntervalSinceNow + 300)) < 5
            }
        }

        describe("pruning") {
            let recentEntry = HistoryItem(
                id: UUID(),
                timestamp: Date(timeIntervalSinceNow: -TimeInterval(5*24*3600)),
                type: .person,
                random: Random())
            let oldEntry = HistoryItem(
                id: UUID(),
                timestamp: Date(timeIntervalSinceNow: -TimeInterval(15*24*3600)),
                type: .person,
                random: Random())

            it("does not affect empty history") {
                expect(historyReducer.reduce(.prune(reason: "test"), historyState()).entries) == []
            }

            it("does not affect recent entries") {
                let daysOldGen = Gen<UInt>.choose((0, 13))
                let dateGen = daysOldGen.map { Date(timeIntervalSinceNow: -TimeInterval($0 * 24 * 3600)) }
                let entriesGen = Gen.compose { composer in
                    HistoryItem(
                        id: composer.generate(),
                        timestamp: dateGen.generate,
                        type: composer.generate(),
                        random: composer.generate()
                    )
                }
                let entries = (0..<50).map { _ in entriesGen.generate }
                let state = historyState(entries: entries)
                expect(historyReducer.reduce(.prune(reason: "test"), state).entries) == state.entries
            }

            it("removes entries older than two weeks") {
                let daysOldGen = Gen<UInt>.choose((14, 28))
                let dateGen = daysOldGen.map { Date(timeIntervalSinceNow: -TimeInterval($0 * 24 * 3600)) }
                let entriesGen = Gen.compose { composer in
                    HistoryItem(
                        id: composer.generate(),
                        timestamp: dateGen.generate,
                        type: composer.generate(),
                        random: composer.generate()
                    )
                }
                let entries = (0..<50).map { _ in entriesGen.generate }
                let state = historyState(entries: entries)
                expect(historyReducer.reduce(.prune(reason: "test"), state).entries) == []
            }

            it("only removes the older ones") {
                let state = historyState(entries: [recentEntry, oldEntry])
                expect(historyReducer.reduce(.prune(reason: "test"), state).entries) == [recentEntry]
            }

            it("records pruning event when nothing pruned") {
                let log = historyReducer.reduce(.prune(reason: "test"), historyState()).pruneLog
                expect(log).to(haveCount(1))
                expect(abs(log[0].timestamp.timeIntervalSinceNow)) < 5
                expect(log[0].numEntriesRemoved) == 0
                expect(log[0].reason) == "test"
            }

            it("records pruning event when something removed") {
                let state = historyState(entries: [recentEntry, oldEntry])
                let log = historyReducer.reduce(.prune(reason: "test"), state).pruneLog
                expect(log).to(haveCount(1))
                expect(abs(log[0].timestamp.timeIntervalSinceNow)) < 5
                expect(log[0].numEntriesRemoved) == 1
                expect(log[0].reason) == "test"
            }
        }
    }
}
