import SwiftUI
import QRCodeReader
import UIKit

struct ZwaaiTab: View {
    var body: some View {
        VStack {
            Text("Zwaai").font(.title)
            QRView().aspectRatio(contentMode: .fit)
        }.tabItem {
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

struct QRView: UIViewControllerRepresentable {
    @State var scannerDelegate: ScannerDelegate = ScannerDelegate()

    func makeUIViewController(context: Context) -> QRCodeReaderViewController {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)

            $0.showTorchButton = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton = false
            $0.showOverlayView = true
            $0.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
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
        print("did scan result", result.value)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        print("did cancel")
    }
}
