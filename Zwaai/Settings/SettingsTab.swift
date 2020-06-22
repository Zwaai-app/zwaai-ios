import Foundation
import SwiftUI

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
                Button(action: resetAppState) {
                    Text("Reset app state")
                }
                .foregroundColor(Color(.systemRed))
            }
            #endif
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Instellingen")
    }

    func resetAppState() {
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
