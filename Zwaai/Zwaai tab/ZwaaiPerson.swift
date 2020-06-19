import SwiftUI
import QRCodeReader
import UIKit

func MyMask(in rect: CGRect) -> Path {
    var shape = Rectangle().path(in: rect)
    let smallerRect = CGRect(x: 15, y: 15,
                             width: rect.width-30,
                             height: rect.height-30)
    shape.addPath(Rectangle().path(in: smallerRect))
    return shape
}

struct ZwaaiPerson: View {
    var body: some View {
        VStack {
            Image("sample-qr")
                .resizable()
                .padding()
                .background(Color(.white))
                .shadow(radius: 2)
                .aspectRatio(contentMode: .fit)

            Text("Richt de telefoons naar elkaar toe, met de voorkant naar elkaar. Het scannen is gelukt zodra één van beide telefoons gaat trillen of het geluid hoorbaar is.")
                .foregroundColor(Color(.text))

            ZStack {
                GeometryReader { geo in
                    QRView()
                    Rectangle().fill(Color.white).mask(
                        MyMask(in: CGRect(x: 0, y: 0, width: geo.size.width, height: geo.size.height))
                            .fill(style: FillStyle(eoFill: true))
                    ).opacity(0.5).blendMode(.colorDodge)
                }
            }.aspectRatio(contentMode: .fit)
            .padding([.leading,.trailing], 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
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

struct QRView: UIViewControllerRepresentable {
    @State var scannerDelegate: ScannerDelegate = ScannerDelegate()

    func makeUIViewController(context: Context) -> QRCodeReaderViewController {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)

            $0.showTorchButton = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton = false
            $0.showOverlayView = false
        }
        let scanner = QRCodeReaderViewController(builder: builder)
        scanner.delegate = scannerDelegate
        return scanner
    }

    func updateUIViewController(_ uiViewController: QRCodeReaderViewController, context: Context) {
    }
}

class ScannerDelegate: QRCodeReaderViewControllerDelegate {
    let feedbackGenerator: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        feedbackGenerator.notificationOccurred(.success)
        AudioFeedback.default.playWaved()
        print("did scan result", result.value)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        print("did cancel")
    }
}
