import Foundation

struct ZwaaiState: Codable, CustomStringConvertible {
    var checkedIn: CheckedInSpace?

    var description: String {
        if let space = checkedIn {
            return "Checked in: \(space)"
        } else {
            return "not checked in"
        }
    }
}

let initialZwaaiState = ZwaaiState(checkedIn: nil)

struct CheckedInSpace: Codable, Equatable {
    let name: String
    let description: String
    let autoCheckout: TimeInterval?
    let deadline: Date?

    init(name: String, description: String, autoCheckout: TimeInterval?) {
        self.name = name
        self.description = description
        self.autoCheckout = autoCheckout
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
    }

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
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
    }

    static func deadline(for timeInterval: TimeInterval?) -> Date? {
        if let timeInterval = timeInterval, timeInterval > 0 {
            return Date(timeIntervalSinceNow: timeInterval)
        } else {
            return nil
        }

    }
}
