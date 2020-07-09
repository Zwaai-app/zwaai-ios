import SwiftUI
import CombineRex
import ZwaaiLogic

struct ZwaaiRuimte: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>

    var body: some View {
        return pickView()
    }

    func pickView() -> AnyView {
        return viewModel.state.checkedIn != nil
            ? AnyView(ZwaaiRuimteCheckedIn(viewModel: viewModel))
            : AnyView(ZwaaiRuimteCheckedOut())
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
    var space: CheckedInSpace { return viewModel.state.checkedIn! }
    @Environment(\.presentationMode) var presentationMode
    @State var showReminderExplanation: Bool = false

    var body: some View {
            VStack {
                Spacer()

                Text("Ingecheckt bij:").font(.title)

                Spacer()

                VStack {
                    Text(verbatim: self.space.name)
                        .font(.largeTitle)
                        .padding([.top, .bottom])
                    Text(verbatim: self.space.description)
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

                ViewBuilder.buildIf(viewModel.state.checkedIn?.deadline.map { (deadline: Date) in
                    VStack {
                        Text("Ruimte wordt automatisch verlaten:")
                            .font(.callout)
                        Text(verbatim: DateFormatter.relativeMedium.string(from: deadline))
                            .font(.callout)
                        Button(action: { self.showReminderExplanation.toggle() }) {
                            VStack {
                                Image(systemName: "alarm")
                                    .accessibility(hidden: true)
                                Text("Herinner me")
                            }
                        }.padding([.top])
                    }.sheet(isPresented: $showReminderExplanation) {
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
                                    Button(action: {}) { Text("Akkoord") }
                                    Spacer()
                                    Button(action: {}) { Text("Niet akkoord") }.foregroundColor(Color(.systemRed))
                                    Spacer()
                                }.frame(maxWidth: .infinity)
                                Button(action: { self.showReminderExplanation.toggle() }) {
                                    Text("Later beslissen")
                                }.foregroundColor(Color(.systemBlue))
                                Spacer()
                            }.padding()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

#if DEBUG
struct ZwaaiRuimte_Previews: PreviewProvider {
    static var previews: some View {
        let space = CheckedInSpace(
            name: "Test Space",
            description: "Somewhere in the universe",
            autoCheckout: 3600
        )
        let viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
            state: ZwaaiViewModel.ViewState(checkedIn: space),
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
