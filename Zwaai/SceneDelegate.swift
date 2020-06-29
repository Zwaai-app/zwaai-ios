import UIKit
import SwiftUI
import ZwaaiView

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
}
