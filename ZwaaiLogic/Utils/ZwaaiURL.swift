import Foundation

public struct ZwaaiURL: Equatable {
    public let type: ZwaaiType

    public init?(from url: URL) {
        guard let scheme = url.scheme,
            ZwaaiURL.valid(scheme: scheme),
            let urlComps = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComps.queryItems,
            let typeString = queryItems.first(where: { $0.name == "type" })?.value,
            ZwaaiURL.valid(typeString: typeString) else {
            return nil
        }

        if typeString == "space" {
            guard let space = CheckedInSpace(from: url) else { return nil }
            self.type = .space(space: space)
        } else {
            guard let randomString = queryItems.first(where: { $0.name == "random" })?.value,
                let random = Random(hexEncoded: randomString) else { return nil }
            self.type = .person(random: random)
        }
    }

    public func toURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "zwaai-app"
        var queryItems: [URLQueryItem] = []
        switch type {
        case .person(let random):
            queryItems.append(URLQueryItem(name: "type", value: "person"))
            queryItems.append(URLQueryItem(name: "random", value: random.hexEncodedString()))
        case .space(let space):
            queryItems.append(URLQueryItem(name: "type", value: "space"))
            queryItems.append(contentsOf: space.toQueryItems())
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
