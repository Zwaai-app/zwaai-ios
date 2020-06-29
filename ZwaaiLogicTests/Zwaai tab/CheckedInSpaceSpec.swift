import SwiftCheck
import XCTest
import Quick
import Nimble
@testable import ZwaaiLogic

class CheckedInSpaceProperties: XCTestCase {
    func testAll() {
        property("to and from URL") <- forAll { (space: CheckedInSpace) in
            let queryItems = space.toQueryItems()
            var urlComps = URLComponents(string: "zwaai-app://")
            urlComps?.queryItems = queryItems
            guard let url = urlComps?.url,
                let newSpace = CheckedInSpace(from: url) else { return false }

            return (space.name == newSpace.name) <?> "name"
                ^&&^
                (space.description == newSpace.description) <?> "description"
                ^&&^
                (space.autoCheckout == newSpace.autoCheckout) <?> "autoCheckout"
        }
    }
}

class CheckedInSpaceSpec: QuickSpec {
    override func spec() {
        it("cannot init with invalid autoCheckout") {
            let url = URL(string: "zwaai-app://?name=test&description=test&autoCheckout=abc")!
            expect(CheckedInSpace(from: url)).to(beNil())
        }
    }
}
