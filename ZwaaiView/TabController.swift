import Foundation
import UIKit
import Combine
import ZwaaiLogic

enum ViewTags: Int {
    case zwaaiTab = 0
    case historyTab = 1
    case settingsTab = 2
}

class TabController: UITabBarController {
    var cancellable: AnyCancellable?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cancellable = appStore().statePublisher.sink { appState in
            guard let tabItem = self.tabBar.items?.first(where: { (item) -> Bool in
                item.tag == ViewTags.settingsTab.rawValue
            }) else { return }
            let hasDiscrepancy = appState.settings.notificationPermission == .allowed
                && appState.meta.systemNotificationPermission != .authorized
            tabItem.badgeValue = hasDiscrepancy ? "" : nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewWillDisappear(animated)
    }
}
