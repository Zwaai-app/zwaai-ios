import SwiftUI

func MyMask(in rect: CGRect) -> Path {
    var shape = Rectangle().path(in: rect)
    let smallerRect = CGRect(x: 15, y: 15,
                             width: rect.width-30,
                             height: rect.height-30)
    shape.addPath(Rectangle().path(in: smallerRect))
    return shape
}

struct ZwaaiPerson: View {
    @State var currentRandom = Random()

    func url() -> String {
        let randomString = currentRandom.base64EncodedString()
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
                        .onTapGesture {
                            self.currentRandom = Random()
                    }
                }

                Text("Richt de telefoons naar elkaar toe, met de voorkant naar elkaar. Het scannen is gelukt zodra één van beide telefoons gaat trillen of het geluid hoorbaar is.")
                    .foregroundColor(Color(.text))

                ZStack {
                    GeometryReader { previewGeo in
                        QRScanner()
                        Rectangle().fill(Color.white).mask(
                            MyMask(in: CGRect(x: 0, y: 0,
                                              width: previewGeo.size.width,
                                              height: previewGeo.size.height))
                                .fill(style: FillStyle(eoFill: true))
                        ).opacity(0.5).blendMode(.colorDodge)
                    }
                }.aspectRatio(contentMode: .fit)
                    .padding([.leading,.trailing], 100)
            }.padding()

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
