import SwiftUI
import CombineRex

struct ZwaaiTab: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>

    var body: some View {
        VStack {
            NavigationLink(destination: ZwaaiPerson()) {
                BigButton(imageName: "logo-button", text: Text("Zwaai met persoon"))
            }
            NavigationLink(destination: ZwaaiRuimte(viewModel: viewModel)) {
                if viewModel.state.checkedIn != nil && viewModel.state.checkedIn!.deadline != nil {
                    BigButton(imageName: "logo-button", text: Text("Ingecheckt tot \(DateFormatter.shortTime.string(from: viewModel.state.checkedIn!.deadline!))"))
                } else if viewModel.state.checkedIn != nil {
                    BigButton(imageName: "logo-button", text: Text("Ingecheckt"))
                } else {
                    BigButton(imageName: "logo-button", text: Text("Zwaai in ruimte"))
                }
            }
        }
        .frame(maxHeight: .infinity)
        .navigationBarTitle(Text("Zwaai"))
        .background(Color(.background))
    }
}

struct ZwaaiTab_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
            state: ZwaaiViewModel.ViewState.empty,
            action: { _, _, _ in })
        return TabView { ZwaaiTab(viewModel: viewModel) }
    }
}

struct BigButton: View {
    var imageName: String
    var text: Text

    var body: some View {
        VStack {
            Image(self.imageName).renderingMode(.original)
            self.text
        }.padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(.zwaaiLogoBg)) // same color as bg of image
            .cornerRadius(8, antialiased: true)
            .shadow(radius: 4)
            .padding(40)
    }
}
