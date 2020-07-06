import Foundation

struct ZwaaiURL {
    public let type: ZwaaiType
    public let random: Random

    public init?(from url: URL) {
        guard let scheme = url.scheme,
            ZwaaiURL.valid(scheme: scheme),
            let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComps.queryItems,
            let randomString = queryItems.first(where: { $0.name == "random" })?.value,
            let random = Random(hexEncoded: randomString),
            let typeString = queryItems.first(where: { $0.name == "type" })?.value,
            ZwaaiURL.valid(typeString: typeString) else {
            return nil
        }

        if let space = CheckedInSpace(from: url), typeString == "space" {
            self.type = .space(space: space)
        } else {
            self.type = .person
        }

        self.random = random
    }

    public func toURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "zwaai-app"
        var queryItems = [
            URLQueryItem(name: "random", value: random.hexEncodedString())
        ]
        if case let .space(space) = self.type {
            queryItems.append(URLQueryItem(name: "type", value: "space"))
            queryItems.append(contentsOf: space.toQueryItems())
        } else {
            queryItems.append(URLQueryItem(name: "type", value: "person"))
        }
        urlComponents.queryItems = queryItems

        return urlComponents.url! // this can only be constructed from URL, so should always succeed
    }

    static func valid(scheme: String) -> Bool {
        return scheme == "zwaai-app"
    }

    static func valid(typeString: String) -> Bool {
        return typeString == "person" || typeString == "space"
    }
}
