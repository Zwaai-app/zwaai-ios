import SwiftUI
import CombineRex
import ZwaaiLogic

struct ZwaaiTab: View {
    @ObservedObject var viewModel: ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>

    var body: some View {
        VStack {
            NavigationLink(destination: ZwaaiPerson()) {
                BigButton(imageName: "logo-button", text: Text("Zwaai met persoon"))
            }
            NavigationLink(destination: ZwaaiRuimte(viewModel: viewModel)) {
                if viewModel.state.checkedInStatus != nil
                    && viewModel.state.checkedInStatus?.succeeded?.deadline != nil
                {
                    BigButton(imageName: "logo-button",
                              text: Text("Ingecheckt tot \(formattedDeadline())"))
                } else if viewModel.state.checkedInStatus?.succeeded != nil {
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

    func formattedDeadline() -> String {
        DateFormatter.shortTime.string(from: viewModel.state.checkedInStatus!.succeeded!.deadline!)
    }
}

#if DEBUG
struct ZwaaiTab_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ObservableViewModel<ZwaaiViewModel.ViewAction, ZwaaiViewModel.ViewState>.mock(
            state: ZwaaiViewModel.ViewState.empty,
            action: { _, _, _ in })
        return TabView { ZwaaiTab(viewModel: viewModel) }
    }
}
#endif

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
