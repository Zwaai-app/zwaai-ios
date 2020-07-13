import SwiftRex
import CombineRex
import UserNotifications

public enum ZwaaiViewModel {
    public static func viewModel<S: StoreType>(from store: S)
        -> ObservableViewModel<ViewAction, ViewState>
        where S.ActionType == AppAction, S.StateType == AppState {

            store.projection(
                action: transform(viewAction:),
                state: transform(appState:)
            ).asObservableViewModel(initialState: .empty)
    }

    public enum ViewAction: Equatable {
        case checkout(space: CheckedInSpace)
        case allowNotifications
        case denyNotifications
    }

    public struct ViewState: Equatable {
        public var checkedIn: CheckedInSpace?
        public var notificationPermission: NotificationPermission
        public var systemNotificationPermissions: UNAuthorizationStatus

        public init(
            checkedIn: CheckedInSpace?,
            notificationPermission: NotificationPermission,
            systemNotificationPermissions: UNAuthorizationStatus
        ) {
            self.checkedIn = checkedIn
            self.notificationPermission = notificationPermission
            self.systemNotificationPermissions = systemNotificationPermissions
        }

        public static let empty: ViewState = ViewState(
            checkedIn: nil,
            notificationPermission: initialSettingsState.notificationPermission,
            systemNotificationPermissions: .notDetermined
        )
    }

    static func transform(viewAction: ViewAction) -> AppAction? {
        switch viewAction {
        case .checkout(let space): return .zwaai(.checkout(space: space))
        case .allowNotifications: return .settings(.set(notificationPermission: .allowed))
        case .denyNotifications: return .settings(.set(notificationPermission: .denied))
        }
    }

    static func transform(appState: AppState) -> ViewState {
        ViewState(checkedIn: appState.zwaai.checkedIn,
                  notificationPermission: appState.settings.notificationPermission,
                  systemNotificationPermissions: appState.meta.systemNotificationPermission ?? .notDetermined)
    }
}
