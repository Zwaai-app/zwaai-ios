import Foundation
import XCTest
import SwiftCheck
@testable import ZwaaiLogic

class HistroyItemProperties: XCTestCase {
    func testAll() {
        property("HistoryZwaaiType can be serialized and deserialized") <- forAll { (type: HistoryZwaaiType) in
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            // swiftlint:disable force_try
            let data = try! encoder.encode(type)
            print(String(data: data, encoding: .utf8)!)
            let decoded = try! decoder.decode(HistoryZwaaiType.self, from: data)

            return decoded == type
        }
    }
}
