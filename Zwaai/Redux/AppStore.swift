import UIKit
import SwiftRex

let appStore: () -> ReduxStoreBase<AppAction, AppState> = {
    // swiftlint:disable:next force_cast
    let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    return appDelegate.appStore
}
