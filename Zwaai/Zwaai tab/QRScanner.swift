import UIKit
import SwiftUI
import QRCodeReader

struct QRScanner: UIViewControllerRepresentable {
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
