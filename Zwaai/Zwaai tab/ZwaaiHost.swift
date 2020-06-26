import SwiftUI
import UIKit

class ZwaaiHost: UIHostingController<ZwaaiTab> {
    required init?(coder aDecoder: NSCoder) {
        let viewModel = ZwaaiViewModel.viewModel(from: appStore())
        super.init(coder: aDecoder, rootView: ZwaaiTab(viewModel: viewModel))
    }
}
