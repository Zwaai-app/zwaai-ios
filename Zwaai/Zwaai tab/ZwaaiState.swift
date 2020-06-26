import Foundation

struct ZwaaiState: Codable, CustomStringConvertible {
    var checkedIn: Space?

    var description: String {
        if let space = checkedIn {
            return "Checked in: \(space)"
        } else {
            return "not checked in"
        }
    }
}

let initialZwaaiState = ZwaaiState(checkedIn: nil)

struct Space: Codable {
    let name: String
    let description: String
    let autoCheckout: TimeInterval?

    init?(from url: URL) {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = comps.queryItems,
            let name = queryItems.first(where: { $0.name == "name" })?.value,
            let description = queryItems.first(where: { $0.name == "description" })?.value,
            let autoCheckoutStr = queryItems.first(where: { $0.name == "autoCheckout" })?.value,
            let autoCheckout = TimeInterval(autoCheckoutStr) else {
                return nil
        }

        self.name = name
        self.description = description
        self.autoCheckout = autoCheckout > 0 ? autoCheckout : nil
    }
}
