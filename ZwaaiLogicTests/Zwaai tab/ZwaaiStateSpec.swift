import XCTest
import SwiftCheck
@testable import ZwaaiLogic

class CheckedInStateProperties: XCTestCase {
    func testAll() {
        property("codable") <- forAll { (state: CheckedInState) in
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // swiftlint:disable force_try
            let data = try! encoder.encode(state)
            let decoded = try! decoder.decode(CheckedInState.self, from: data)

            return decoded == state
        }
    }
}
