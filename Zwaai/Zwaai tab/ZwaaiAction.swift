import Foundation

typealias Random = [UInt8]

enum ZwaaiAction {
    case didScanUrl(url: URL)
    case didScanRandom(base64encodedRandom: String)
}
