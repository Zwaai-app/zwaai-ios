import UIKit
import SwiftRex
import CombineRex

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var appStore: ReduxStoreBase<AppAction, AppState>!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        do {
            let initialState = try loadAppState().get()
            appStore = ReduxStoreBase<AppAction, AppState>(
                subject: .combine(initialValue: initialState),
                reducer: appReducer,
                middleware: appMiddleware
            )
        } catch let error {
            fatalError("Failed to load app state: " + error.localizedDescription)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
