import UIKit
import SwiftUI
import ZwaaiView
import ZwaaiLogic

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard scene is UIWindowScene else { return }

        window?.tintColor = .appTint
        UINavigationBar.appearance().tintColor = .white
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.async {
            appStore().dispatch(.history(.prune(reason: "didBecomeActive")))
            appStore().dispatch(.meta(.notification(action: .checkSystemPermissions)))
            appStore().dispatch(.meta(.notification(action: .getPending)))
            appStore().dispatch(.meta(.setupAutoCheckout))
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard URLContexts.count == 1,
            let first = URLContexts.first,
            let zwaaiURL = ZwaaiURL(from: first.url),
            zwaaiURL.type.isSpace
            else {
                return
        }

        DispatchQueue.main.async {
            appStore().dispatch(.history(.addEntry(url: zwaaiURL)))
            appStore().dispatch(.meta(.zwaaiSucceeded(presentingController: self.window!.rootViewController!,
                                                      onDismiss: {})))
        }
    }
}
