// sourcery: Prism
enum AppAction {
    case history(HistoryAction)
    case zwaai(ZwaaiAction)
    case meta(AppMetaAction)
    case resetAppState
}
