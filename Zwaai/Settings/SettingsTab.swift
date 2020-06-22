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
                primaryButton: .destructive(Text("Delete"), action: resetAppState),
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
#endif
