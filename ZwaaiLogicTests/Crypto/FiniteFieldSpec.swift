import XCTest
import Quick
import Nimble
@testable import ZwaaiLogic
import Clibsodium

// swiftlint:disable identifier_name

class FiniteFieldSpec: QuickSpec {
    override func spec() {
        it("can generate a random scalar") {
            let r1 = Scalar.random()
            let r2 = Scalar.random()
            expect(r1.count) == Scalar.size
            expect(r1) != r2
        }

        it("can generate a random group element") {
            let r1 = GroupElement.random()
            let r2 = GroupElement.random()
            expect(r1.count) == GroupElement.size
            expect(r1) != r2
        }

        it("can generate a random group element with seed") {
            let seed1: [UInt8] = (0..<randombytes_SEEDBYTES).map { _ in UInt8.random(in: 0...255) }
            let seed2: [UInt8] = (0..<randombytes_SEEDBYTES).map { _ in UInt8.random(in: 0...255) }
            expect(seed1) != seed2
            let r1_1 = GroupElement.randomDeterministic(seed: seed1)
            let r1_2 = GroupElement.randomDeterministic(seed: seed1)
            let r2_1 = GroupElement.randomDeterministic(seed: seed2)
            let r2_2 = GroupElement.randomDeterministic(seed: seed2)
            expect(r1_1) == r1_2
            expect(r1_1) != r2_1
            expect(r2_1) == r2_2
        }

        it("can multiply and divide") {
            let s = Scalar.random()
            let g = GroupElement.random()
            let sg = s * g
            let gPrime = sg / s
            XCTAssertEqual(gPrime, g)
        }

        it("can do a single round") {
            let (l, lt, t) = singleRound()
            XCTAssertEqual(l, lt / t)
        }

        it("fails to decvode invalid hex string") {
            expect(GroupElement(hexEncoded: "invalid")).to(beNil())
        }

        it("can encode a group element to a hex string") {
            let g = GroupElement.random()
            let hex = g.hexEncodedString()
            let gPrime = GroupElement(hexEncoded: hex)!
            expect(gPrime) == g
        }
    }
}

class FiniteFieldPerformanceTests: XCTestCase {
    func testBruteFoceLookupLocation() throws {
        // 5 mins -> 4032 possible time codes in two weeks

        let knownTimeCodes = (0..<4032).map { _ in Scalar.random() }
        let knownLocations = (0..<100).map { _ in GroupElement.random() }

        self.measure {
            let randomL = knownLocations.randomElement()!
            let randomT = knownTimeCodes.randomElement()!
            let randomLT = randomT * randomL

            var foundL: GroupElement?
            _ = knownTimeCodes.first { t in
                let maybeL = (randomLT / t)
                foundL = knownLocations.first { $0 == maybeL }
                return foundL != nil
            }

            XCTAssertNotNil(foundL)
        }
    }
}
