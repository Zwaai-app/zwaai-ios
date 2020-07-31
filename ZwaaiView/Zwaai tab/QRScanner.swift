import UIKit
import SwiftUI
import QRCodeReader
import ZwaaiLogic

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
            $0.reader = QRCodeReader(
                metadataObjectTypes: [.qr],
                captureDevicePosition: role == .person ? .front : .back)
            $0.showTorchButton = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton = false
            $0.showOverlayView = false
        }
        let scanner = QRCodeReaderViewController(builder: builder)
        scanner.delegate = context.coordinator
        #if targetEnvironment(simulator)
        addManualTestingControls(scanner: scanner, context: context)
        #endif
        return scanner
    }

    #if targetEnvironment(simulator)
    func addManualTestingControls(
        scanner: QRCodeReaderViewController,
        context: Context
    ) {
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
    }
    #endif

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

        func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
            self.reader(reader, didScanValue: result.value, metadataType: result.metadataType)
        }

        func reader(_ reader: QRCodeReaderViewController, didScanValue value: String, metadataType: String) {
            let restartScanning = { reader.startScanning() }
            if let url = URL(string: value),
                let zwaaiURL = ZwaaiURL(from: url) {
                appStore().dispatch(.zwaai(.didScan(url: zwaaiURL)))
                appStore().dispatch(.meta(.zwaaiSucceeded(url: zwaaiURL,
                                                          presentingController: reader,
                                                          onDismiss: restartScanning)))
            } else {
                appStore().dispatch(.meta(.zwaaiFailed(presentingController: reader,
                                                       onDismiss: restartScanning)))
            }
        }

        func readerDidCancel(_ reader: QRCodeReaderViewController) {}

        #if targetEnvironment(simulator)
        @objc func fakeScanSucceeded() {
            guard let scanner = self.scanner else { return }
            let sampleValue = role == .person
                ? "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=person"
                : "zwaai-app:?random=3816dba2ea2a7c2109ab7ac60f21de47&type=space&locationCode=c24bb15548b831f43d1cb639510df9e009252e84e42e6f7bb8e20106ca972b41&name=HTC33%20Atelier%205&description=All%20open%20spaces&autoCheckout=28800" // swiftlint:disable:this line_length
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
