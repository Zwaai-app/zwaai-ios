import SwiftUI
import SwiftRex

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        let viewModel = HistoryViewModel.viewModel(from: appStore)
        return TabView(selection: $selection){
            ZwaaiTab().tag(0)
            HistoryTab(viewModel: viewModel).tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
