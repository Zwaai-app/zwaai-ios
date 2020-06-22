import XCTest
import SwiftCheck
@testable import Zwaai

// swiftlint:disable identifier_name

class FunctionalProgrammingProperties: XCTestCase {
    func testAll() {
        property("composes single-arg functions") <- forAll { (x: Int) in
            let f = { (a: Int) in a - 3 }
            let g = { (b: Int) in b / 5 }
            return (f•g)(x) == f(g(x))
        }

        property("composes no-arg function") <- forAll { (x: Int) in
            let f = { (a: Int) in a - 3 }
            let g = { return x / 5}
            return (f•g)() == f(g())
        }

        property("iterates") <- forAll { (n: UInt) in
            let a = iterate(n) { 3 }
            return a.filter { $0 ==  3 }.count == n
        }

        property("iterates curried") <- forAll { (n: UInt) in
            let a = iterate(n)({ "x" })
            return a.filter { $0 == "x" }.count == n
        }
    }
}
