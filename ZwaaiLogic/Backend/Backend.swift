import Foundation

class Backend {
    var hostname = ""
    let deps: BackendDeps

    init(deps: BackendDeps = BackendDeps()) {
        self.deps = deps
    }

    func withHostName(completion: (_ hostname: String) -> Void) {
        #if DEV_MODE
        if hostname == "" {
            loadBuildInfo { _, _, hostname in
                self.hostname = hostname
                completion(hostname)
            }
        } else {
            completion(hostname)
        }
        #else
        fatal("host name for release mode not configured")
        #endif
    }
}

// MARK: - Testability

class BackendDeps {
    var createSession: (URLSessionConfiguration) -> URLSessionProto
        = { URLSession(configuration: $0) }
}

protocol URLSessionProto {
    func uploadTaskTestable(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTaskProto
}

extension URLSession: URLSessionProto {
    func uploadTaskTestable(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTaskProto {
        return uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}

protocol URLSessionUploadTaskProto {
    func resume()
}
extension URLSessionUploadTask: URLSessionUploadTaskProto {}
