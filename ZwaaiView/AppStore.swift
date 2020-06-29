import UIKit
import SwiftRex
import ZwaaiLogic

public protocol AppDelegateWithStore {
    var appStore: ReduxStoreBase<AppAction, AppState>! { get }
}

let appStore: () -> ReduxStoreBase<AppAction, AppState> = {
    // swiftlint:disable:next force_cast
    let appDelegate = UIApplication.shared.delegate! as! AppDelegateWithStore
    return appDelegate.appStore
}
