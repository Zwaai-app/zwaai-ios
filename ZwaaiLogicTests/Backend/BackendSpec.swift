import Foundation
@testable import ZwaaiLogic

class URLSessionMock: URLSessionProto {
    var createdTasks = [URLSessionUploadTaskSpy]()
    var taskResponseData: Data?
    var taskResponseCode: Int?
    var taskError: Error?

    func uploadTaskTestable(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTaskProto {
        let task = URLSessionUploadTaskSpy(
            with: request,
            from: bodyData,
            responseData: taskResponseData,
            responseCode: taskResponseCode,
            error: taskError,
            completionHandler: completionHandler
        )
        createdTasks.append(task)
        return task
    }
}

class URLSessionUploadTaskSpy: URLSessionUploadTaskProto {
    let request: URLRequest
    let bodyData: Data?
    let completionHandler: (Data?, URLResponse?, Error?) -> Void
    let responseData: Data?
    let responseCode: Int?
    let error: Error?

    init(
        with request: URLRequest,
        from bodyData: Data?,
        responseData: Data?,
        responseCode: Int?,
        error: Error?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        self.request = request
        self.bodyData = bodyData
        self.responseData = responseData
        self.responseCode = responseCode
        self.error = error
        self.completionHandler = completionHandler
    }

    func resume() {
        DispatchQueue.main.async {
            if let error = self.error {
                self.completionHandler(self.responseData, nil, error)
            } else if let responseCode = self.responseCode {
                let response = HTTPURLResponse(
                    url: self.request.url!,
                    statusCode: responseCode,
                    httpVersion: "1.1",
                    headerFields: [:])
                self.completionHandler(self.responseData, response, nil)
            } else if self.responseData == nil {
                self.completionHandler(nil, nil, nil)
            } else {
                let response = HTTPURLResponse(
                    url: self.request.url!,
                    mimeType: "application/json",
                    expectedContentLength: 0,
                    textEncodingName: nil)
                self.completionHandler(self.responseData, response, nil)
            }
        }
    }
}
