import SwiftUI

struct ZwaaiTab: View {
    var body: some View {
        VStack {
            NavigationLink(destination: ZwaaiPerson()) {
                BigButton(imageName: "logo-button", text: Text("Zwaai met persoon"))
            }
            NavigationLink(destination: ZwaaiPerson()) {
                BigButton(imageName: "logo-button", text: Text("Zwaai in ruimte"))
            }
        }
        .frame(maxHeight: .infinity)
        .navigationBarTitle(Text("Zwaai"))
        .background(Color(.background))
    }
}

struct ZwaaiTab_Previews: PreviewProvider {
    static var previews: some View {
        TabView { ZwaaiTab() }
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
