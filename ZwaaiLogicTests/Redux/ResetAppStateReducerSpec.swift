import SwiftCheck
import XCTest
@testable import ZwaaiLogic

class ResetAppStateReducerProperties: XCTestCase {
    func testAll() {
        property("reset clears state") <- forAll { (appState: AppState) in
            return resetAppStateReducer.reduce(.resetAppState, appState) == initialAppState
        }

        property("ignores other action") <- forAll { (appState: AppState) in
            return resetAppStateReducer.reduce(.history(.lock), appState) == appState
        }
    }
}
