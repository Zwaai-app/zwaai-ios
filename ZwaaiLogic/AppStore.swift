import UIKit
import SwiftRex

public protocol AppDelegateWithStore {
    var appStore: ReduxStoreBase<AppAction, AppState>! { get }
}

public func appStore(_ appDelegate: UIApplicationDelegate = UIApplication.shared.delegate!)
    -> ReduxStoreBase<AppAction, AppState> {
        // swiftlint:disable:next force_cast
        let appDelegate = appDelegate as! AppDelegateWithStore
        return appDelegate.appStore
}
