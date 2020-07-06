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

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard URLContexts.count == 1,
            let first = URLContexts.first,
            let comps = URLComponents(url: first.url, resolvingAgainstBaseURL: false),
            let queryItems = comps.queryItems,
            let type = queryItems.first(where: { $0.name == "type" })?.value,
            type == "space" else {
                return
        }

        appStore().dispatch(.history(.addEntry(url: first.url)))
    }
}
