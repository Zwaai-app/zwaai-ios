import SwiftUI
import UIKit

class HistoryHost: UIHostingController<HistoryTab> {
    required init?(coder aDecoder: NSCoder) {
        let viewModel = HistoryViewModel.viewModel(from: appStore())
        super.init(coder: aDecoder, rootView: HistoryTab(viewModel: viewModel))
    }
}
