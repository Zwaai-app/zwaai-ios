import SwiftUI
import UIKit

class ZwaaiHost: UIHostingController<ZwaaiTab> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ZwaaiTab())
    }
}
