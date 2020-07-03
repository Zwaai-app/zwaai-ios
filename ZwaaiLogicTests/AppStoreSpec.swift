import Quick
import Nimble
import ZwaaiLogic
import UIKit
import SwiftRex

class AppStoreSpec: QuickSpec {
    override func spec() {
        it("takes app store from app delegate") {
            let spy = AppDelegateSpy()
            let store = appStore(spy)
            expect(store).to(beIdenticalTo(spy.appStore))
        }
    }
}

class AppDelegateSpy: UIResponder, UIApplicationDelegate, AppDelegateWithStore {
    var appStore: ReduxStoreBase<AppAction, AppState>!
        = ReduxStoreBase<AppAction, AppState>(
            subject: .combine(initialValue: initialAppState),
            reducer: Reducer.identity,
            middleware: IdentityMiddleware())
}
