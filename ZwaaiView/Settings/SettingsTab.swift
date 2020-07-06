import Foundation
import SwiftUI
import Swift
import CombineRex
import ZwaaiLogic

struct SettingsTab: View {
    let zwaaiUrl = "https://zwaai.app"

    @ObservedObject var viewModel: ObservableViewModel<SettingsViewModel.ViewAction, SettingsViewModel.ViewState>

    #if DEV_MODE
    @ObservedObject var buildInfo = BuildInfo()
    #endif

    var body: some View {
        List {
            Section(header: Text("Over Zwaai")) {
                Button(action: browseToSite) {
                    (Text("Ga naar ").foregroundColor(Color(.label))
                    + Text(verbatim: zwaaiUrl).foregroundColor(Color(.appTint))
                    + Text(" in de browser")).foregroundColor(Color(.label))
                }.accessibility(hint: Text("Schakelt over naar je browser om de homepage van Zwaai te laten zien"))

                KeyValueRow(label: Text("App versie"), value: appVersion())
            }
            #if DEV_MODE
            Section(header: Text("Developer")) {
                NavigationLink(destination: PruneLogView(
                    logEntries: $viewModel.state.pruneLog,
                    pruneAction: { self.viewModel.dispatch(.pruneHistory(reason: "manual")) })) {
                    Text("Prune log")
                }
                KeyValueRow(label: Text("Last saved"), value: DateFormatter.relativeMedium.string(from: Date()))
                KeyValueRow(label: Text("Commit"), value: buildInfo.commitHash)
                KeyValueRow(label: Text("Branch"), value: buildInfo.branch)
                GenerateTestData()
                ResetAppStateButton(resetAppState: {
                    self.viewModel.dispatch(.resetAppState)
                })
            }
            #endif
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Instellingen")
    }
}

#if DEBUG
struct SettingsHost_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ObservableViewModel<
        SettingsViewModel.ViewAction, SettingsViewModel.ViewState>.mock(
            state: SettingsViewModel.ViewState(lastSaved: "one minute ago", pruneLog: []),
            action: {_, _, _ in })
        return TabView { SettingsTab(viewModel: viewModel) }
    }
}
#endif

func browseToSite() {
    guard let url = URL(string: "https://zwaai.app") else { return }
    UIApplication.shared.open(url)
}

func appVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ?? "?"
}

#if DEV_MODE
struct ResetAppStateButton: View {
    @State var showResetConfirmation = false
    var resetAppState: () -> Void

    var body: some View {
        Button(action: showAlert) {
            Text("Reset app state")
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset state?"),
                message: Text("If you proceed, all app data will be deleted."),
                primaryButton: .destructive(Text("Reset"), action: resetAndDismiss),
                secondaryButton: .cancel(Text("Cancel"), action: hideAlert))
        }
        .foregroundColor(Color(.systemRed))
    }

    func showAlert() {
        self.showResetConfirmation = true
    }

    func hideAlert() {
        self.showResetConfirmation = false
    }

    func resetAndDismiss() {
        self.resetAppState()
        hideAlert()
    }
}

struct GenerateTestData: View {
    var body: some View {
        Button(action: addTestData) {
            Text("Generate test data")
        }
    }

    func addTestData() {
        let testData = generateTestActions()
        let store = appStore()
        testData.forEach { action in
            store.dispatch(action)
        }
    }

    func generateTestActions() -> [AppAction] {
        let days: UInt = 14
        let itemsPerDay: UInt = 6

        let randomItem = {
            randomHistoryItem(maxPastInterval: TimeInterval(days*24*3600))
        }
        let toAction = { (item: HistoryItem) in
            return AppAction.history(.addItem(item: item))
        }
        return iterate(days * itemsPerDay)(randomItem)
            .sorted()
            .map(toAction)
    }
}

struct PruneLogView: View {
    @Binding var logEntries: [PruneEvent]
    var pruneAction: () -> Void

    var body: some View {
        List(logEntries) { item in
            HStack {
                Text(verbatim: DateFormatter.relativeMedium.string(from: item.timestamp))
                Spacer()
                Text(verbatim: "\(item.reason)/\(item.numEntriesRemoved)")
            }
        }.navigationBarItems(trailing: Button(action: pruneAction) { Text("Prune") })
    }
}
#endif

extension Array where Element == HistoryItem {
    func sorted() -> [HistoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            item1.timestamp <= item2.timestamp
        }
    }
}

func randomHistoryItem(maxPastInterval: TimeInterval) -> HistoryItem {
    let interval = TimeInterval.random(in: 0 ..< maxPastInterval)
    let timestamp = Date(timeIntervalSinceNow: -interval)
    let space = CheckedInSpace(name: "Test Space", description: "Somewhere", autoCheckout: nil)
    let type: ZwaaiType = Bool.random() ? .person : .space(space: space)
    let random = Random()
    return HistoryItem(id: UUID(), timestamp: timestamp, type: type, random: random)
}
