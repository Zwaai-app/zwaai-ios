import Quick
import Nimble
@testable import ZwaaiLogic

class HistoryStateSpec: QuickSpec {
    override func spec() {
        it("tells whether the lock is open") {
            expect(LockState.locked.isOpen()).to(beFalse())
            expect(LockState.unlocking.isOpen()).to(beFalse())
            expect(LockState.unlocked.isOpen()).to(beTrue())
        }

        it("has proper string representation for UI") {
            expect(LockState.locked.actionString()) == "Toon"
            expect(LockState.unlocked.actionString()) == "Verberg"
            expect(LockState.unlocking.actionString()) == "..."
        }
    }
}
