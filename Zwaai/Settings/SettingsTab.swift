import Foundation
import SwiftUI

struct SettingsTab: View {
    var body: some View {
        List {
            Section(header: Text("Over Zwaai")) {
                HStack {
                    Text("Ga naar")
                    Button(action: { browseToSite() }) {
                        Text("https://zwaai.app")
                    }
                    Text("in de browser")
                }
                HStack {
                    Text("App versie")
                    Spacer()
                    Text(verbatim: appVersion())
                }
            }
            #if DEBUG
            Section(header: Text("Developer")) {
                Button(action: {}) {
                    Text("Reset app state")
                }
                .foregroundColor(Color(.systemRed))
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
