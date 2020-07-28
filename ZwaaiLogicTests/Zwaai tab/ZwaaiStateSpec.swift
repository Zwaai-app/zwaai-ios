import XCTest
import SwiftCheck
@testable import ZwaaiLogic

class CheckedInStatusProperties: XCTestCase {
    func testAll() {
        property("codable") <- forAll { (state: ActionStatus<CheckedInSpace>) in
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // swiftlint:disable force_try
            let data = try! encoder.encode(state)
            let decoded = try! decoder.decode(ActionStatus<CheckedInSpace>.self, from: data)

            return decoded == state
        }
    }
}
