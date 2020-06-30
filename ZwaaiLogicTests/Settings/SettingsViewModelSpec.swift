import SwiftCheck
import XCTest
@testable import ZwaaiLogic

class SettingsViewModelProperties: XCTestCase {
    func testAll() {
        property("transforms actions") <- {
            return SettingsViewModel.transform(viewAction: .resetAppState)
                == AppAction.resetAppState
        }

        property("transforms state") <- forAll { (appState: AppState) in
            let viewState = SettingsViewModel.transform(appState: appState)

            if let lastSaved = appState.meta.lastSaved {
                switch lastSaved {
                case .failure:
                    return viewState.lastSaved.starts(with: "Error:")
                case .success(let date):
                    let formattedDate = DateFormatter.relativeMedium.string(from: date)
                    return viewState == SettingsViewModel.ViewState(lastSaved: formattedDate)
                }
            } else {
                return viewState == SettingsViewModel.ViewState(lastSaved: "---")
            }
        }
    }
}
