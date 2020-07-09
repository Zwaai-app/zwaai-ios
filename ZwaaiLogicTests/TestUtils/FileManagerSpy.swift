import Foundation
@testable import ZwaaiLogic

class FileManagerSpy: FileManagerProto {
    var fileExists: Bool
    var urls: [FileManager.SearchPathDirectory: URL]
    var createdDirectories = [(URL, Bool, [FileAttributeKey: Any]?)]()
    var copiedItems = [(URL, URL)]()
    var createShouldThrow: Error?

    init(fileExists: Bool = false,
         urls: [FileManager.SearchPathDirectory: URL] = [:]) {
        self.fileExists = fileExists
        self.urls = urls
    }

    func fileExists(atPath path: String) -> Bool {
        return fileExists
    }

    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [URL](urls.filter { (dir, _) in dir == directory }.values)
    }

    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey: Any]? = nil) throws {
        if let error = createShouldThrow {
            throw error
        } else {
            createdDirectories.append((url, createIntermediates, attributes))
        }
    }

    func copyItem(at srcURL: URL, to dstURL: URL) throws {
        copiedItems.append((srcURL, dstURL))
    }
}
