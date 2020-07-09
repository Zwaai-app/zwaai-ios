import UIKit

extension UIColor {
    public static var appTint = UIColor(named: "appTint") ?? UIColor.systemGreen
    public static var text = UIColor.secondaryLabel
    public static var background = UIColor.systemBackground
    public static var zwaaiLogoBg = UIColor(named: "zwaaiLogoBg")
        ?? UIColor(white: 0xf9/0xff, alpha: 1) // asset doesn't work in unit test
}
