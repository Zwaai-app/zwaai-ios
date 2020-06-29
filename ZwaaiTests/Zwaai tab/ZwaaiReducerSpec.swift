import XCTest
import SwiftCheck
import Quick
import Nimble
@testable import ZwaaiLogic

class ZwaaiReducerProperties: XCTestCase {
    func testAll() {
        property("checkin stores space") <- forAll { (state: ZwaaiState, space: CheckedInSpace) in
            let newState = zwaaiReducer.reduce(.checkin(space: space), state)
            return newState.checkedIn == space
        }

        property("checkout clears space") <- forAll { (state: ZwaaiState, space: CheckedInSpace) in
            let newState = zwaaiReducer.reduce(.checkout(space: space), state)
            if state.checkedIn != nil && state.checkedIn == space {
                return newState.checkedIn == nil
            } else {
                return newState == state
            }
        }
    }
}

class ZwaaiReducerSpec: QuickSpec {
    override func spec() {
        it("checks out matching space") {
            let space = CheckedInSpace(name: "test", description: "test", autoCheckout: nil)
            let state = ZwaaiState(checkedIn: space)
            let newState = zwaaiReducer.reduce(.checkout(space: space), state)
            expect(newState.checkedIn).to(beNil())
        }
    }
}
