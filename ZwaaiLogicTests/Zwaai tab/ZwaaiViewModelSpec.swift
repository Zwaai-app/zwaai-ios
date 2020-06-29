import XCTest
import SwiftCheck
@testable import ZwaaiLogic

class ZwaaiViewModelSpec: XCTestCase {
    func testAll() {
        property("translates actions") <- forAll { (space: CheckedInSpace) in
            return ZwaaiViewModel.transform(viewAction: .checkout(space: space))
                == AppAction.zwaai(.checkout(space: space))
        }

        property("translates state") <- forAll { (appState: AppState) in
            return ZwaaiViewModel.transform(appState: appState)
                == ZwaaiViewModel.ViewState(checkedIn: appState.zwaai.checkedIn)
        }
    }
}
