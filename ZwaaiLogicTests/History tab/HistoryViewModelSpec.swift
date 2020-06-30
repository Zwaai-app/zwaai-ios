import SwiftCheck
import XCTest
import SwiftRex
import CombineRex
@testable import ZwaaiLogic

class HistoryViewModelProperties: XCTestCase {
    func testAll() {
        property("transform action") <- {
            return HistoryViewModel.transform(viewAction: .lock) == AppAction.history(.lock)
                ^&&^
                HistoryViewModel.transform(viewAction: .tryUnlock) == AppAction.history(.tryUnlock)
        }

        property("transform state") <- forAll { (appState: AppState) in
            return HistoryViewModel.transform(appState: appState)
                == HistoryViewModel.ViewState(
                    entries: appState.history.entries,
                    lock: appState.history.lock,
                    personCount: appState.history.allTimePersonZwaaiCount,
                    spaceCount: appState.history.allTimeSpaceZwaaiCount)
        }
    }
}
