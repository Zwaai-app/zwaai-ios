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

                Spacer()

                Button(action: checkout) {
                    Text("Nu verlaten").font(.title)
                }

                ViewBuilder.buildIf(viewModel.state.checkedIn?.deadline.map { (deadline: Date) in
                    VStack {
                        Text("Ruimte wordt automatisch verlaten:")
                            .font(.callout)
                        Text(verbatim: DateFormatter.relativeMedium.string(from: deadline))
                            .font(.callout)
                    }.padding([.top])
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
