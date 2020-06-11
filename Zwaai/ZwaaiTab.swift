import SwiftUI

struct ZwaaiTab: View {
    var body: some View {
        Text("Zwaai")
            .font(.title)
            .tabItem {
                VStack {
                    Image("zwaai-tab")
                    Text("Zwaai")
                }
        }
    }
}

struct ZwaaiTab_Previews: PreviewProvider {
    static var previews: some View {
        TabView() { ZwaaiTab() }
    }
}
