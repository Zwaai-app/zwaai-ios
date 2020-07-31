import SwiftCheck
import XCTest
import Quick
import Nimble
@testable import ZwaaiLogic

class CheckedInSpaceProperties: XCTestCase {
    func testAll() {
        property("to and from URL") <- forAll { (space: CheckedInSpace) in
            let queryItems = space.toQueryItems()
            var urlComps = URLComponents(string: "zwaai-app:")
            urlComps?.queryItems = queryItems
            guard let url = urlComps?.url,
                let newSpace = CheckedInSpace(from: url) else { return false }

            return (space.name == newSpace.name) <?> "name"
                ^&&^
                (space.locationCode == newSpace.locationCode) <?> "locationCode"
                ^&&^
                (space.desc == newSpace.desc) <?> "description"
                ^&&^
                (space.autoCheckout == newSpace.autoCheckout) <?> "autoCheckout"
        }
    }
}

class CheckedInSpaceSpec: QuickSpec {
    override func spec() {
        it("is has no checked out date initially") {
            let space1 = CheckedInSpace(name: "space1",
                                        locationCode: GroupElement.random(),
                                        description: "desc1",
                                        autoCheckout: nil,
                                        locationTimeCodes: [])
            expect(space1.checkedOut).to(beNil())
        }

        it("can be checked out") {
            let space1 = CheckedInSpace(name: "space1",
                                        locationCode: GroupElement.random(),
                                        description: "desc1",
                                        autoCheckout: nil,
                                        locationTimeCodes: [])
            let date = Date()
            expect(space1.checkout(at: date).checkedOut) == date
        }

        it("cannot init with invalid autoCheckout") {
            let locationCode = GroupElement.random().hexEncodedString()
            let url = URL(string:
                "zwaai-app:?name=test&locationCode=\(locationCode)&description=test&autoCheckout=abc")!
            expect(CheckedInSpace(from: url)).to(beNil())
        }
    }
}

func testSpace(
    name: String = "test",
    locationCode: GroupElement = GroupElement.random(),
    description: String = "test",
    autoCheckout: Seconds? = nil,
    deadline: Date? = nil
) -> CheckedInSpace {
    if deadline == nil && autoCheckout != nil {
        return CheckedInSpace(name: name,
                              locationCode: locationCode,
                              description: description,
                              autoCheckout: autoCheckout,
                              locationTimeCodes: [])
    } else {
        return CheckedInSpace(name: name,
                              locationCode: locationCode,
                              description: description,
                              autoCheckout: autoCheckout,
                              deadline: deadline,
                              locationTimeCodes: [])
    }
}
