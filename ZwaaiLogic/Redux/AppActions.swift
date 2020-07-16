public enum AppAction: Equatable, Prism {
    case history(HistoryAction)
    case zwaai(ZwaaiAction)
    case settings(SettingsAction)
    case meta(AppMetaAction)
    case resetAppState
}
