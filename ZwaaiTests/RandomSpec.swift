import Foundation
import Quick
import Nimble
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
