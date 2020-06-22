import SwiftUI
import UIKit

class SettingsHost: UIHostingController<SettingsTab> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsTab())
    }
}
