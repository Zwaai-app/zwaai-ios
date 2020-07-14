import SwiftCheck
import XCTest
import Quick
import Nimble

class HexEncodingProperties: XCTestCase {
    func testAll() {
        property("it can encode and decode") <- forAll { (bytes: [UInt8]) in
            let data = Data(bytes)
            let reconstructed = Data(hexEncoded: data.hexEncodedString())
            if bytes.count == 0 {
                return reconstructed == nil
            } else {
                return reconstructed == data
            }
        }
    }
}

class HexEncodingSpec: QuickSpec {
    override func spec() {
        it("cannot initialize from invalid string") {
            expect(Data(hexEncoded: "")).to(beNil())
            expect(Data(hexEncoded: "0x00")).to(beNil())
            expect(Data(hexEncoded: "ABC")).to(beNil())
            expect(Data(hexEncoded: "XY")).to(beNil())
        }
    }
}
