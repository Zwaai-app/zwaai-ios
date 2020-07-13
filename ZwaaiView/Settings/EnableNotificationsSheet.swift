import Foundation
import SwiftUI
import CombineRex
import ZwaaiLogic
import UserNotifications

struct EnableNotificationsSheet: View {
    var onAllowNotifications: () -> Void
    var onDenyNotifications: () -> Void
    var requestPermissionsFromSystem: (_ completionHandler: @escaping (Bool, Error?) -> Void) -> Void
        = requestLocalNotificationPermission

    @Binding var isPresented: Bool
    @Binding var systemPermissions: UNAuthorizationStatus
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
                    Button(action: self.allowNotifications) { Text("Akkoord") }
                    Spacer()
                    Button(action: self.denyNotifications) { Text("Niet akkoord") }
                        .foregroundColor(Color(.systemRed))
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
        if systemPermissions == .notDetermined {
            self.requestPermissionsFromSystem { _, _ in
                self.isPresented = false
            }
        } else {
            self.isPresented = false
        }
        DispatchQueue.main.async {
            self.onAllowNotifications()
        }
    }

    func denyNotifications() {
        self.isPresented = false
        DispatchQueue.main.async {
            self.onDenyNotifications()
        }
    }
}
