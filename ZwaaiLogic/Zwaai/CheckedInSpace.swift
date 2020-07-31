import Foundation

public typealias Seconds = Int

public struct CheckedInSpace: Codable, Equatable {
    public let id: UUID
    public let name: String
    public let locationCode: GroupElement
    public let desc: String
    public let autoCheckout: Seconds?
    public let deadline: Date?
    public let checkedOut: Date?
    public let locationTimeCodes: [GroupElement]

    private init(id: UUID,
                 name: String,
                 locationCode: GroupElement,
                 desc: String,
                 autoCheckout: Seconds?,
                 deadline: Date?,
                 checkedOut: Date?,
                 locationTimeCodes: [GroupElement]) {
        self.id = id
        self.name = name
        self.locationCode = locationCode
        self.desc = desc
        self.autoCheckout = autoCheckout
        self.deadline = deadline
        self.checkedOut = checkedOut
        self.locationTimeCodes = locationTimeCodes
    }

    public init(name: String, locationCode: GroupElement, description: String,
                autoCheckout: Seconds?, locationTimeCodes: [GroupElement]) {
        self.id = UUID()
        self.name = name
        self.locationCode = locationCode
        self.desc = description
        self.autoCheckout = autoCheckout
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
        self.checkedOut = nil
        self.locationTimeCodes = locationTimeCodes
    }

    init(name: String, locationCode: GroupElement, description: String,
         autoCheckout: Seconds?, deadline: Date?, locationTimeCodes: [GroupElement]) {
        self.id = UUID()
        self.name = name
        self.locationCode = locationCode
        self.desc = description
        self.autoCheckout = autoCheckout
        self.deadline = deadline
        self.checkedOut = nil
        self.locationTimeCodes = locationTimeCodes
    }

    init(from space: CheckedInSpace, locationTimeCodes: [GroupElement]) {
        self.id = space.id
        self.name = space.name
        self.locationCode = space.locationCode
        self.desc = space.desc
        self.autoCheckout = space.autoCheckout
        self.deadline = space.deadline
        self.checkedOut = space.checkedOut
        self.locationTimeCodes = locationTimeCodes
    } // TODO: Issue #2: this will be a factory method on ZwaaiURL

    public init?(from url: URL) {
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = comps.queryItems,
            let name = queryItems.first(where: { $0.name == "name" })?.value,
            let locationCodeStr = queryItems.first(where: { $0.name == "locationCode" })?.value,
            let locationCode = GroupElement(hexEncoded: locationCodeStr),
            let description = queryItems.first(where: { $0.name == "description" })?.value,
            let autoCheckoutStr = queryItems.first(where: { $0.name == "autoCheckout" })?.value,
            let autoCheckout = Int(autoCheckoutStr) else {
                return nil
        }

        self.id = UUID()
        self.name = name
        self.locationCode = locationCode
        self.desc = description
        self.autoCheckout = autoCheckout > 0 ? autoCheckout : nil
        self.deadline = CheckedInSpace.deadline(for: autoCheckout)
        self.checkedOut = nil
        self.locationTimeCodes = [] // TODO: See issue #2
    }

    func toQueryItems() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "locationCode", value: locationCode.hexEncodedString()),
            URLQueryItem(name: "description", value: desc),
            URLQueryItem(name: "autoCheckout", value: autoCheckout.map(String.init) ?? "-1")
        ]
    }

    func checkout(at date: Date) -> CheckedInSpace {
        return CheckedInSpace(
            id: self.id,
            name: self.name,
            locationCode: self.locationCode,
            desc: self.desc,
            autoCheckout: self.autoCheckout,
            deadline: self.deadline,
            checkedOut: date,
            locationTimeCodes: self.locationTimeCodes)
    }

    static func deadline(for seconds: Seconds?) -> Date? {
        guard let seconds = seconds, seconds > 0 else {
            return nil
        }
        return Date(timeIntervalSinceNow: TimeInterval(seconds))
    }
}
