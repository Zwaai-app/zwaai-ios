import SwiftUI

struct ZwaaiRuimte: View {
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

struct ZwaaiRuimte_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                ZwaaiRuimte()
                    .navigationBarTitle(Text("Zwaai"), displayMode: .inline)
            }.tabItem { Text("Zwaai") }
        }
    }
}
