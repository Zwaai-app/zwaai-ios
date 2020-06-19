import Foundation
import UIKit
import CoreImage

func generateQRCode(from string: String, size: CGSize) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)

    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue(String("Q"), forKey: "inputCorrectionLevel")

    guard let output = filter.outputImage else { return nil }
    let ctx = CIContext(options: nil)
    let scaleUp = CGAffineTransform(scaleX: size.width/output.extent.width,
                                    y: size.height/output.extent.height)
    guard let cgImage = ctx.createCGImage(output.transformed(by: scaleUp),
                                          from: CGRect(origin: .zero, size: size)
        ) else { return nil }

    return UIImage(cgImage: cgImage)
}
