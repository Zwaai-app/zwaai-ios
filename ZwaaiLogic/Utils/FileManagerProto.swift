import Foundation

protocol FileManagerProto {
    func fileExists(atPath path: String) -> Bool
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey: Any]?) throws
    func copyItem(at srcURL: URL, to dstURL: URL) throws
}

extension FileManager: FileManagerProto {}

extension FileManagerProto {
    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(at: url,
                            withIntermediateDirectories: createIntermediates,
                            attributes: nil)
    }
}
