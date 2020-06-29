import UIKit
import SwiftRex
import CombineRex
import ZwaaiLogic
import ZwaaiView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateWithStore {

    var appStore: ReduxStoreBase<AppAction, AppState>!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let initialState: AppState
        do {
            initialState = try loadAppState().get()
        } catch let error {
            #if DEBUG
            initialState = initialAppState
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Fatal error",
                    message: "Failed to load app state: " + error.localizedDescription
                    + ". App state was reset to initial state.",
                    preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .destructive))
                application.windows.first?.rootViewController?.present(alert, animated: true)
            }
            #else
            fatalError("Failed to load app state: " + error.localizedDescription)
            #endif
        }
        appStore = ReduxStoreBase<AppAction, AppState>(
            subject: .combine(initialValue: initialState),
            reducer: appReducer,
            middleware: appMiddleware
        )

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
