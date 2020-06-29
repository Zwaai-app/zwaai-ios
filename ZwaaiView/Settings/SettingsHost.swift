import SwiftUI
import UIKit
import ZwaaiLogic

class SettingsHost: UIHostingController<SettingsTab> {
    required init?(coder aDecoder: NSCoder) {
        let viewModel = SettingsViewModel.viewModel(from: appStore())
        super.init(coder: aDecoder, rootView: SettingsTab(viewModel: viewModel))
    }
}
