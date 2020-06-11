import SwiftUI

struct HistoryTab: View {
    var body: some View {
        Text("Geschiedenis")
            .font(.title)
            .tabItem {
                VStack {
                    Image(systemName: "clock")
                    Text("Geschiedenis")
                }
        }
    }
}

struct HistoryTab_Previews: PreviewProvider {
    static var previews: some View {
        TabView() { HistoryTab() }
    }
}
