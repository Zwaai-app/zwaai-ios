import UIKit
import SwiftUI
import QRCodeReader

enum ScanResult: Equatable {
    case didNotScanYet
    case succeeded(url: URL)
    case failed
}

struct QRScanner: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> QRCodeReaderViewController {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)

            $0.showTorchButton = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton = false
            $0.showOverlayView = false
        }
        let scanner = QRCodeReaderViewController(builder: builder)
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: QRCodeReaderViewController, context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, QRCodeReaderViewControllerDelegate {
        var parent: QRScanner

        init(_ parent: QRScanner) {
            self.parent = parent
        }

        let feedbackGenerator: UINotificationFeedbackGenerator = {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        }()

        func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
            feedbackGenerator.notificationOccurred(.success)
            AudioFeedback.default.playWaved()
            let restartScanning = { reader.startScanning() }
            let alert: UIAlertController
            if let url = URL(string: result.value) {
                appStore.dispatch(.history(.addEntry(url: url)))
                alert = succeededAlert(onDismiss: restartScanning)
            } else {
                alert = failedAlert(onDismiss: restartScanning)
            }
            reader.present(alert, animated: true)
        }

        func readerDidCancel(_ reader: QRCodeReaderViewController) {}
    }
}

func succeededAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString("Gelukt", comment: "Success: Scan succeeded alert title")
    let message = NSLocalizedString("Het uitwisselen van de random is gelukt. De random blijft op uw toestel en wordt niet opgestuurd.", comment: "Scan succeeded alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString("Volgende", comment: "Next: User dismisses info alert that scan succeeded")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .default, handler: { _ in onDismiss() }
    ))
    return alert
}

func failedAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString("Mislukt", comment: "Failure: Scan failed alert title")
    let message = NSLocalizedString("Het uitwisselen van de random is niet gelukt. Probeer het nog eens. Houd de toestellen in dezelfde richting, met de schermen naar elkaar toe, en niet te dichtbij elkaar.", comment: "Scan failed alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString("Nogmaals", comment: "Retry: user dismisses alert that scan failed")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .destructive, handler: { _ in onDismiss() }
    ))
    return alert
}

