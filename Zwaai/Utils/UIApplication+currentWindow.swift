import UIKit

extension UIApplication {
    /// Returns a scene's current window. If the app is showing twice,
    /// e.g. on an iPad, it's not clear which one is returned.
    var currentWindow: UIWindow? {
        connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    }
}
