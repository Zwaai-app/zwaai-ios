// sourcery: Prism
public enum AppAction: Equatable {
    case history(HistoryAction)
    case zwaai(ZwaaiAction)
    case meta(AppMetaAction)
    case resetAppState
}
