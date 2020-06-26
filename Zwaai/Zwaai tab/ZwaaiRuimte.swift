import SwiftUI
import CombineRex

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

            ScannerWithMask(role: .room)
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
    var space: Space { return viewModel.state.checkedIn! }

    var body: some View {
            VStack {
                Spacer()

                Text("Ingecheckt bij:").font(.title)

                Spacer()

                Text(verbatim: self.space.name)
                    .font(.largeTitle)
                    .padding([.top, .bottom])
                Text(verbatim: self.space.description)

                Spacer()

                Button(action: checkout) {
                    Text("Checkout")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.background))
            .navigationBarTitle("Ingecheckt")
    }

    func checkout() {
        viewModel.dispatch(.checkout)
    }
}

struct ZwaaiRuimte_Previews: PreviewProvider {
    static var previews: some View {
        let space = Space(
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
