import UIKit
import SwiftUI
import QRCodeReader

enum ScanResult: Equatable {
    case didNotScanYet
    case succeeded(url: URL)
    case failed
}

enum ScannerRole {
    case person
    case space
}

struct QRScanner: UIViewControllerRepresentable {
    let role: ScannerRole

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
        #if targetEnvironment(simulator)
        context.coordinator.scanner = scanner
        DispatchQueue.main.async {
            let barButtonSucceeded = UIBarButtonItem(
                title: "✓",
                style: .plain,
                target: scanner.delegate,
                action: #selector(Coordinator.fakeScanSucceeded))
            barButtonSucceeded.tintColor = .systemGreen
            barButtonSucceeded.accessibilityLabel = "Fake successful scan"
            let barButtonFailed = UIBarButtonItem(
                title: "𐄂",
                style: .plain,
                target: scanner.delegate,
                action: #selector(Coordinator.fakeScanFailed)
            )
            barButtonFailed.tintColor = .systemRed
            barButtonFailed.accessibilityLabel = "Fake failed scan"
            scanner.parent?.navigationItem.rightBarButtonItems
                = [barButtonFailed, barButtonSucceeded]
        }
        #endif
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: QRCodeReaderViewController, context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, role: self.role)
    }

    class Coordinator: NSObject, QRCodeReaderViewControllerDelegate {
        var parent: QRScanner
        let role: ScannerRole
        #if targetEnvironment(simulator)
        var scanner: QRCodeReaderViewController?
        #endif

        init(_ parent: QRScanner, role: ScannerRole) {
            self.parent = parent
            self.role = role
        }

        let feedbackGenerator: UINotificationFeedbackGenerator = {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        }()

        func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
            self.reader(reader, didScanValue: result.value, metadataType: result.metadataType)
        }

        func reader(_ reader: QRCodeReaderViewController, didScanValue value: String, metadataType: String) {
            feedbackGenerator.notificationOccurred(.success)
            AudioFeedback.default.playWaved()
            let restartScanning = { reader.startScanning() }
            let alert: UIAlertController
            if let url = URL(string: value) {
                appStore().dispatch(.history(.addEntry(url: url)))
                alert = succeededAlert(onDismiss: restartScanning)
            } else {
                alert = failedAlert(onDismiss: restartScanning)
            }
            reader.present(alert, animated: true)
        }

        func readerDidCancel(_ reader: QRCodeReaderViewController) {}

        #if targetEnvironment(simulator)
        @objc func fakeScanSucceeded() {
            guard let scanner = self.scanner else { return }
            let sampleValue = role == .person
                ? "zwaai-app://?random=86d5fe975f54e246857d3133b68494ab&type=person"
                : "zwaai-app://?random=3816dba2ea2a7c2109ab7ac60f21de47&type=space&name=HTC33%20Atelier%205&description=All%20open%20spaces&autoCheckout=28800" // swiftlint:disable:this line_length
            self.reader(scanner, didScanValue: sampleValue, metadataType: "org.iso.QRCode")
        }

        @objc func fakeScanFailed() {
            guard let scanner = self.scanner else { return }
            let sampleValue = "invalid value"
            self.reader(scanner, didScanValue: sampleValue, metadataType: "org.iso.QRCode")
        }
        #endif
    }
}

func succeededAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString(
        "Success",
        tableName: "QRScanner",
        comment: "Scan succeeded alert title")
    let message = NSLocalizedString(
        "scan succeeded alert message",
        tableName: "QRScanner",
        comment: "Scan succeeded alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString(
        "Proceed",
        tableName: "QRScanner",
        comment: "Scan succeeded alert dismiss button label")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .default, handler: { _ in onDismiss() }
    ))
    return alert
}

func failedAlert(onDismiss: @escaping () -> Void) -> UIAlertController {
    let title = NSLocalizedString(
        "Failed",
        tableName: "QRScanner",
        comment: "Scan failed alert title")
    let message = NSLocalizedString(
        "scan failed alert message",
        tableName: "QRScanner",
        comment: "Scan failed alert message")
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismiss = NSLocalizedString(
        "Retry",
        tableName: "QRScanner",
        comment: "Scan failed alert dismiss button label")
    alert.addAction(UIAlertAction(
        title: dismiss,
        style: .destructive, handler: { _ in onDismiss() }
    ))
    return alert
}
