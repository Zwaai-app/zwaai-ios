import SwiftUI

struct ZwaaiPerson: View {
    @State var currentRandom = Random()

    func url() -> String {
        let randomString = currentRandom.hexEncodedString()
        return "zwaai-app://?random=\(randomString)&type=person"
    }

    func qr(size: CGSize) -> UIImage {
        return generateQRCode(
            from: self.url(),
            size: CGSize(width: size.width, height: size.width)
        )!
    }

    var body: some View {
        Group {
            VStack {
                GeometryReader { imageGeo in
                    Image(uiImage: self.qr(size: imageGeo.size))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                        .accessibility(label: Text("QR code die de ander moet scannen"))
                        .accessibility(sortPriority: 1)
                }

                Text("Richt de telefoons naar elkaar toe, met de voorkant naar elkaar. Het scannen is gelukt zodra één van beide telefoons gaat trillen of het geluid hoorbaar is.") // swiftlint:disable:this line_length
                    .accessibility(sortPriority: 2)
                    .foregroundColor(Color(.text))

                ScannerWithMask(role: .person)
                    .padding([.leading, .trailing], 100)

            }.padding()
                .accessibilityElement(children: .contain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.background))
        .navigationBarTitle("Persoon")
    }
}

struct ZwaaiPerson_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                ZwaaiPerson()
                    .navigationBarTitle(Text("Zwaai"), displayMode: .inline)
            }.tabItem { Text("Zwaai") }
        }
    }
}
