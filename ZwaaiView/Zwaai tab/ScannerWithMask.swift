import SwiftUI

struct ScannerWithMask: View {
    let role: ScannerRole

    var body: some View {
        ZStack {
            GeometryReader { previewGeo in
                QRScanner(role: self.role)
                Rectangle().fill(Color.white).mask(
                    camPreviewMask(in: CGRect(x: 0, y: 0,
                                      width: previewGeo.size.width,
                                      height: previewGeo.size.height))
                        .fill(style: FillStyle(eoFill: true))
                ).opacity(0.5).blendMode(.colorDodge)
                    .accessibility(label: Text("Camera voorvertoning voor scannen"))
                    .accessibility(sortPriority: 0)
            }
        }.aspectRatio(contentMode: .fit)
    }
}

func camPreviewMask(in rect: CGRect) -> Path {
    var shape = Rectangle().path(in: rect)
    let smallerRect = CGRect(x: 15, y: 15,
                             width: rect.width-30,
                             height: rect.height-30)
    shape.addPath(Rectangle().path(in: smallerRect))
    return shape
}
