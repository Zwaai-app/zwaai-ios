import UIKit

extension UIColor {
    static var appTint = UIColor(named: "appTint")!
    static var text = UIColor.secondaryLabel
    static var background = UIColor.systemBackground
    static var zwaaiLogoBg = UIColor(named: "zwaaiLogoBg")
        ?? UIColor(white: 0xf9/0xff, alpha: 1) // asset doesn't work in unit test
}
