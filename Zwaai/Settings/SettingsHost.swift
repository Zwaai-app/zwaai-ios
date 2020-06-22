import SwiftUI
import UIKit

class SettingsHost: UIHostingController<SettingsTab> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsTab())
    }
}

struct SettingsTab: View {
    var body: some View {
        List { Text("TODO") }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Instellingen")
    }
}
