import Foundation
import XCTest
import SwiftCheck
@testable import ZwaaiLogic

class ZwaaiTypeProperties: XCTestCase {
    func testAll() {
        property("ZwaaiType can be serialized and deserialized") <- forAll { (type: ZwaaiType) in
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // swiftlint:disable force_try
            let data = try! encoder.encode(type)
            let decoded = try! decoder.decode(ZwaaiType.self, from: data)

            return decoded == type
        }
    }
}
