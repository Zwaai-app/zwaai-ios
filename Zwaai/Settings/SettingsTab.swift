import Foundation
import SwiftUI
import Swift

struct SettingsTab: View {
    #if DEBUG
    @ObservedObject var buildInfo = BuildInfo()
    #endif

    var body: some View {
        List {
            Section(header: Text("Over Zwaai")) {
                HStack {
                    Text("Ga naar")
                    Button(action: browseToSite) {
                        Text("https://zwaai.app")
                    }
                    Text("in de browser")
                }
                KeyValueRow(label: Text("App versie"), value: appVersion())
            }
            #if DEBUG
            Section(header: Text("Developer")) {
                KeyValueRow(label: Text("Commit"), value: buildInfo.commitHash)
                KeyValueRow(label: Text("Branch"), value: buildInfo.branch)
                GenerateTestData()
                ResetAppStateButton()
            }
            #endif
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Instellingen")
    }
}

struct SettingsHost_Previews: PreviewProvider {
    static var previews: some View {
        return TabView { SettingsTab() }
    }
}

func browseToSite() {
    guard let url = URL(string: "https://zwaai.app") else { return }
    UIApplication.shared.open(url)
}

func appVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        ?? "?"
}

#if DEBUG
struct ResetAppStateButton: View {
    @State var showResetConfirmation = false

    var body: some View {
        Button(action: showAlert) {
            Text("Reset app state")
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset state?"),
                message: Text("If you proceed, all app data will be deleted."),
                primaryButton: .destructive(Text("Reset"), action: resetAppState),
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

    func resetAppState() {
        appStore().dispatch(.resetAppState)
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
            return AppAction.history(.addTestItem(entry: item))
        }
        return iterate(days * itemsPerDay)(randomItem)
            .sorted()
            .map(toAction)
    }
}
#endif

extension Array where Element == HistoryItem {
    func sorted() -> [HistoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            item1.timestamp > item2.timestamp
        }
    }
}

func randomHistoryItem(maxPastInterval: TimeInterval) -> HistoryItem {
    let interval = TimeInterval.random(in: 0 ..< maxPastInterval)
    let timestamp = Date(timeIntervalSinceNow: -interval)
    let type: ZwaaiType = Bool.random() ? .person : .room
    let random = Random()
    return HistoryItem(id: UUID(), timestamp: timestamp, type: type, random: random)
}
