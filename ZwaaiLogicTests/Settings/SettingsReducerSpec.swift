import Quick
import Nimble
@testable import ZwaaiLogic

class SettingsReducerSpec: QuickSpec {
    override func spec() {
        describe("set notification permissions") {
            let states = [
                SettingsState(notificationPermission: .undecided),
                SettingsState(notificationPermission: .allowed),
                SettingsState(notificationPermission: .denied)
            ]

            it("recudes set allowed") {
                let action: SettingsAction = .set(notificationPermission: .allowed)
                states.forEach {
                    expect(settingsReducer.reduce(action, $0).notificationPermission) == .allowed
                }
            }

            it("recudes set denied") {
                let action: SettingsAction = .set(notificationPermission: .denied)
                states.forEach {
                    expect(settingsReducer.reduce(action, $0).notificationPermission) == .denied
                }
            }

            it("does not reduce set undecided") {
                let action: SettingsAction = .set(notificationPermission: .undecided)
                states.forEach {
                    expect(settingsReducer.reduce(action, $0).notificationPermission) == $0.notificationPermission
                }
            }
        }
    }
}
