import Foundation
import SwiftUI
import CombineRex
import ZwaaiLogic

struct EnableNotificationsSheet: View {
    var onAllowNotifications: () -> Void
    var onDenyNotifications: () -> Void
    var requestPermissionsFromSystem: (_ completionHandler: @escaping (Bool, Error?) -> Void) -> Void
        = requestLocalNotificationPermission

    @State var deniedToSystemWhileAllowedHere: Bool = false
    @Binding var isPresented: Bool
    internal let inspection = Inspection<Self>() // for view test

    var body: some View {
        VStack {
            Group {
                Text("Toestemming")
                    .font(.title)
                    .foregroundColor(Color(.appTint))
                    .padding([.top])
                (
                    Text(verbatim: "Zwaai").foregroundColor(Color(.appTint))
                        + Text(" kan berichtgeving gebruiken om u een herinnering te geven wanneer een ruimte automatisch wordt verlaten, voor het geval u vergeet het handmatig te doen. U kunt dan opnieuw inchecken als dat nodig is.") // swiftlint:disable:this line_length
                    ).lineLimit(nil)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: self.allowNotifications) {
                        Text("Akkoord")
                    }.alert(isPresented: self.$deniedToSystemWhileAllowedHere) {
                        Alert(
                            title: Text("Geen toestemming"),
                            message: Text("De app heeft geen toestemming voor berichtgeving gekregen. U kunt dit in de app instellingen corrigeren."), // swiftlint:disable:this line_length
                            primaryButton: .default(Text("Open instellingen")) { self.openIosAppSettings() },
                            secondaryButton: .cancel(Text("Niet nu")) {
                                self.isPresented = false
                            })
                    }
                    Spacer()
                    Button(action: self.denyNotifications) {
                        Text("Niet akkoord")
                    }.foregroundColor(Color(.systemRed))
                    Spacer()
                }.frame(maxWidth: .infinity)
                Button(action: { self.isPresented = false }) {
                    Text("Later beslissen")
                }.foregroundColor(Color(.systemBlue))
                Spacer()
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) } // for view test
    }

    func allowNotifications() {
        self.requestPermissionsFromSystem { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[error] While requesting notification permission: \(error)")
                }
                if !granted {
                    self.onDenyNotifications()
                    self.deniedToSystemWhileAllowedHere.toggle()
                } else {
                    self.isPresented = false
                    self.onAllowNotifications()
                }
            }
        }
    }

    func denyNotifications() {
        self.isPresented = false
        self.onDenyNotifications()
    }

    func openIosAppSettings() {
        guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }

        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
    }
}
