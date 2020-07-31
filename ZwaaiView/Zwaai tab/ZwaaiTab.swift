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
                } else if viewModel.state.checkedInStatus?.isPending ?? false {
                    BigButton(imageName: nil, text: Text("Bezig met inchecken…"))
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
    var imageName: String? // TODO: allow for activity indicator
    var text: Text

    var icon: AnyView {
        if imageName != nil {
            return AnyView(Image(imageName!).renderingMode(.original))
        } else {
            return AnyView(ActivityIndicator(isAnimating: .constant(true), style: .large))
        }
    }

    var body: some View {
        VStack {
            icon
            self.text
        }.padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(.zwaaiLogoBg)) // same color as bg of image
            .cornerRadius(8, antialiased: true)
            .shadow(radius: 4)
            .padding(40)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
