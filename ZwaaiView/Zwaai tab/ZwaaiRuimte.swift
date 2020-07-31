import SwiftUI
import CombineRex
import ZwaaiLogic
import Combine

struct ZwaaiRuimte: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>

    var body: some View {
        return pickView()
    }

    func pickView() -> AnyView {
        if viewModel.state.checkedInStatus?.isSucceeded ?? false {
            return AnyView(ZwaaiRuimteCheckedIn(viewModel: viewModel))
        } else if viewModel.state.checkedInStatus?.isPending ?? false {
            return AnyView(ZwaaiRuitmeCheckinPending(viewModel: viewModel))
        } else {
            return AnyView(ZwaaiRuimteCheckedOut())
        }
    }
}

struct ZwaaiRuimteCheckedOut: View {
    var body: some View {
        VStack {
            Spacer()

            Text("Scan de QR code van de ruimte om in te checken. Na het scannen ziet u of en zo ja wanneer u weer automatisch uitgecheckt wordt.") // swiftlint:disable:this line_length

            Spacer()

            ScannerWithMask(role: .space)
                .padding([.leading, .trailing, .bottom])
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.background))
        .navigationBarTitle("Ruimte")
    }
}

struct ZwaaiRuimteCheckedIn: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>
    var space: CheckedInSpace { return viewModel.state.checkedInStatus!.succeeded! }
    @Environment(\.presentationMode) var presentationMode
    @State var showReminderExplanation = false
    var hasPermissionDiscrepancy: Bool {
        viewModel.state.notificationPermission == .allowed
            && viewModel.state.systemNotificationPermissions != .authorized
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Ingecheckt bij:").font(.title)

            Spacer()

            VStack {
                Text(verbatim: self.space.name)
                    .font(.largeTitle)
                    .padding([.top, .bottom])
                Text(verbatim: self.space.desc)
                    .padding([.top, .bottom])
            }.frame(maxWidth: .infinity)
                .background(Color(.zwaaiLogoBg)) // same color as bg of image
                .cornerRadius(8, antialiased: true)
                .shadow(radius: 4)
                .accessibilityElement(children: .combine)

            Spacer()

            Button(action: checkout) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .rotationEffect(.degrees(90))
                        .accessibility(hidden: true)
                        .font(.title)
                    Text("Nu verlaten").font(.title)
                }
            }

            Spacer()

            ViewBuilder.buildIf(viewModel.state.checkedInStatus?.succeeded?.deadline.map { (deadline: Date) in
                VStack {
                    Text("Ruimte wordt automatisch verlaten:")
                        .font(.callout)
                    Text(verbatim: DateFormatter.relativeMedium.string(from: deadline))
                        .font(.callout)

                    if self.isScheduled {
                        Image(systemName: "alarm")
                            .accessibility(label: Text("Herinnering staat aan"))
                    } else {
                        Group {
                            if viewModel.state.notificationPermission == .undecided
                                ||  viewModel.state.systemNotificationPermissions == .notDetermined {
                                Button(action: { self.showReminderExplanation.toggle() }) {
                                    VStack {
                                        Image(systemName: "alarm")
                                            .accessibility(hidden: true)
                                        Text("Herinner me")
                                    }
                                }.padding([.top])
                            } else if hasPermissionDiscrepancy {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(Color(.systemRed))
                                    Text("Berichtgeving werkt niet")
                                    Text("Ga naar instellingen voor deatils.")
                                }.padding([.top])
                            } else {
                                Button(action: { self.scheduleReminder() }) {
                                    VStack {
                                        Image(systemName: "alarm")
                                            .accessibility(hidden: true)
                                        Text("Herinner me")
                                    }
                                }.padding([.top])
                            }
                        }
                    }
                }
                .onAppear { self.checkReminderScheduled() }
                .sheet(isPresented: $showReminderExplanation) {
                    EnableNotificationsSheet(
                        onAllowNotifications: {
                            self.scheduleReminder()
                            self.viewModel.dispatch(.allowNotifications)
                        },
                        onDenyNotifications: { self.viewModel.dispatch(.denyNotifications) },
                        isPresented: self.$showReminderExplanation,
                        systemPermissions: self.$viewModel.state.systemNotificationPermissions
                    )
                }
            })

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.background))
        .navigationBarTitle("Ingecheckt")
    }

    func checkout() {
        viewModel.dispatch(.checkout(space: space))
        presentationMode.wrappedValue.dismiss()
    }

    func scheduleReminder() {
        scheduleLocalNotification(space: space) { _ in
            DispatchQueue.main.async {
                self.checkReminderScheduled()
            }
        }
    }

    @State var isScheduled = false

    func checkReminderScheduled() {
        isLocalNotificationPending(space: space) { pending in
            self.isScheduled = pending
        }
    }
}

struct ZwaaiRuitmeCheckinPending: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>

    var body: some View {
        VStack {
            ActivityIndicator(isAnimating: .constant(true), style: .large)
            Text("Bezig met inchecken…")

            Button(action: { self.viewModel.dispatch(.cancelCheckin) }) {
                Text("Annuleren").foregroundColor(Color(.systemRed))
            }.padding([.top])
        }
    }
}

#if DEBUG
struct ZwaaiRuimte_Previews: PreviewProvider {
    static var previews: some View {
        let space = CheckedInSpace(
            name: "Test Space",
            locationCode: GroupElement.random(),
            description: "Somewhere in the universe",
            autoCheckout: 3600,
            locationTimeCodes: [.random()]
        )
        let viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
            state: ZwaaiViewModel.ViewState(
                checkedInStatus: .succeeded(value: space),
                notificationPermission: .undecided,
                systemNotificationPermissions: .notDetermined
            ),
            action: { _, _, _ in })

        return TabView {
            NavigationView {
                ZwaaiRuimte(viewModel: viewModel)
                    .navigationBarTitle(Text("Zwaai"), displayMode: .inline)
            }.tabItem { Text("Zwaai") }
        }
    }
}
#endif
