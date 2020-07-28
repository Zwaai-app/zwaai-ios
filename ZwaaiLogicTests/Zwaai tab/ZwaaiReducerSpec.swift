import XCTest
import SwiftCheck
import Quick
import Nimble
@testable import ZwaaiLogic

class ZwaaiReducerProperties: XCTestCase {
    func testAll() {
        property("checkinPending updates state") <- forAll { (state: ZwaaiState) in
            let newState = zwaaiReducer.reduce(.checkinPending, state)
            return newState.checkedInStatus == .pending
        }

        property("checkinSucceeded updates state") <- forAll { (state: ZwaaiState, space: CheckedInSpace) in
            let newState = zwaaiReducer.reduce(.checkinSucceeded(space: space), state)
            return newState.checkedInStatus == .succeeded(value: space)
        }

        property("checkinFailed updates state") <- forAll { (state: ZwaaiState, reason: String) in
            let newState = zwaaiReducer.reduce(.checkinFailed(reason: reason), state)
            return newState.checkedInStatus == .failed(reason: reason)
        }

        property("checkin stores space") <- forAll { (state: ZwaaiState, space: CheckedInSpace) in
            let newState = zwaaiReducer.reduce(.checkin(space: space), state)
            return newState.checkedIn == space
        }
    }
}

class ZwaaiReducerSpec: QuickSpec {
    override func spec() {
        it("ignores didScan because that is handled by middleware") {
            let state = ZwaaiState()
            let url = ZwaaiURL(from: validPersonURL)!
            expect(zwaaiReducer.reduce(.didScan(url: url), state)) == state
        }

        it("checks out matching space") {
            let space = testSpace()
            let state = ZwaaiState(checkedIn: space)
            let newState = zwaaiReducer.reduce(.checkout(space: space), state)
            expect(newState.checkedIn).to(beNil())
        }

        it("does not check out non-matching space") {
            let space1 = testSpace(name: "one")
            let space2 = testSpace(name: "two")
            let state = ZwaaiState(checkedIn: space1)
            let newState = zwaaiReducer.reduce(.checkout(space: space2), state)
            expect(newState.checkedIn) == space1
        }
    }
}
