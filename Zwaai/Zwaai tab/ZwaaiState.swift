import Foundation

struct ZwaaiState: Codable, CustomStringConvertible, Equatable {
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

typealias Seconds = Int

struct CheckedInSpace: Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let autoCheckout: Seconds?
    let deadline: Date?
    var checkedOut: Date?

    public init(name: String, description: String, autoCheckout: Seconds?) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.autoCheckout = autoCheckout
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
        self.checkedOut = nil
    }

    init(name: String, description: String, autoCheckout: Seconds?, deadline: Date?) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.autoCheckout = autoCheckout
        self.deadline = deadline
        self.checkedOut = nil
    }

    init?(from url: URL) {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = comps.queryItems,
            let name = queryItems.first(where: { $0.name == "name" })?.value,
            let description = queryItems.first(where: { $0.name == "description" })?.value,
            let autoCheckoutStr = queryItems.first(where: { $0.name == "autoCheckout" })?.value,
            let autoCheckout = Int(autoCheckoutStr) else {
                return nil
        }

        self.id = UUID()
        self.name = name
        self.description = description
        self.autoCheckout = autoCheckout > 0 ? autoCheckout : nil
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
        self.checkedOut = nil
    }

    static func deadline(for seconds: Seconds?) -> Date? {
        if let seconds = seconds, seconds > 0 {
            return Date(timeIntervalSinceNow: TimeInterval(seconds))
        } else {
            return nil
        }
    }
}
