import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            Text("Zwaai")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("zwaai-tab")
                        Text("Zwaai")
                    }
                }
                .tag(0)
            Text("Geschiedenis")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("Geschiedenis")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
