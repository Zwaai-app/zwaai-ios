// sourcery: Prism
public enum AppAction: Equatable {
    case history(HistoryAction)
    case zwaai(ZwaaiAction)
    case settings(SettingsAction)
    case meta(AppMetaAction)
    case resetAppState
}
