import Foundation

import Quick
import Nimble

import XCTest
import SwiftCheck

@testable import Zwaai

class RandomSpec: QuickSpec {
    override func spec() {
        it("can generate hex representation") {
            let bytes = Data([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])
            let random = Random(bytes: bytes)!
            expect(random.hexEncodedString()) == "0102030405060708090a0b0c0d0e0f10"
        }
    }
}

class RandomProperties: XCTestCase {
    func testAll() {
        property("randoms can be hex serialized and deserialized") <- forAll { (r: Random) in
            return Random(hexEncoded: r.hexEncodedString()) == r
        }

        property("hex encoding is 32 characters") <- forAll { (r: Random) in
            return r.hexEncodedString().count == 32
        }
    }
}

extension Random: Arbitrary {
    public static var arbitrary: Gen<Random> {
        let bytes = UInt8.arbitrary.proliferate(withSize: 16)
        return bytes.flatMap {
            Gen<Random>.pure(Random(bytes: Data($0))!)
        }
    }
}
