import SwiftCheck
import XCTest
@testable import ZwaaiLogic

class AppErrorProperties: XCTestCase {
    func testAll() {
        property("equals") <- forAll { (error: AppError) in
            let otherError: AppError
            switch error {
            case .noUserDocumentsDirectory: otherError = .invalidZwaaiType(type: "foo")
            default: otherError = .noUserDocumentsDirectory
            }

            return (error == error) <?> "equals"
                ^&&^
                (error != otherError) <?> "not equals"
        }
    }
}
