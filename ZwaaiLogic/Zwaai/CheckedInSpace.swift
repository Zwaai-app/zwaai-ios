import Foundation

public typealias Seconds = Int

public struct CheckedInSpace: Codable, Equatable {
    public let id: UUID
    public let name: String
    public let description: String
    public let autoCheckout: Seconds?
    public let deadline: Date?
    public var checkedOut: Date?

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

    public init?(from url: URL) {
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

    func toQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "description", value: description),
            URLQueryItem(name: "autoCheckout", value: autoCheckout.map(String.init) ?? "-1")
        ]
    }

    static func deadline(for seconds: Seconds?) -> Date? {
        guard let seconds = seconds, seconds > 0 else {
            return nil
        }
        return Date(timeIntervalSinceNow: TimeInterval(seconds))
    }
}
