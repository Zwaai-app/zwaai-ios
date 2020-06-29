import SwiftCheck
import XCTest
import Quick
import Nimble

class HexEncodingProperties: XCTest {
    func testAll() {
        property("it can encode and decode") <- forAll { (bytes: [UInt8]) in
            let data = Data(bytes)
            return Data(hexEncoded: data.hexEncodedString()) == data
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
