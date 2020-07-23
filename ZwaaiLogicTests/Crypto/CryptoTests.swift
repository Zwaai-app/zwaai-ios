import XCTest
import ZwaaiLogic
import Clibsodium

// swiftlint:disable identifier_name

class CryptoSpikeTests: XCTestCase {

    func testSingleRound() throws {
        let (l, lt, t) = singleRound()
        XCTAssertEqual(l, lt / t)
    }

    func testIsRandom() throws {
        let (l1, lt1, t1) = singleRound()
        let (l2, lt2, t2) = singleRound()

        XCTAssertNotEqual(l1, l2)
        XCTAssertNotEqual(lt1, lt2)
        XCTAssertNotEqual(t1, t2)
    }

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
