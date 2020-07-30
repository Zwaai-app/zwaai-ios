import Quick
import Nimble
@testable import ZwaaiLogic

class CombineLocationWithTimeSpec: QuickSpec {
    override func spec() {
        let encLoc = GroupElement.random()
        var deps: BackendDeps!
        var backend: CombineLocationWithTime!
        var sessionMock: URLSessionMock!

        beforeEach {
            deps = BackendDeps()
            sessionMock = URLSessionMock()
            deps.createSession = { _ in return sessionMock }
            backend = CombineLocationWithTime(deps: deps)
        }

        it("uses a proper request") {
            let encLoc = GroupElement.random()
            backend.run(encryptedLocation: encLoc) {_, _ in }
            expect(sessionMock.createdTasks.first).toEventuallyNot(beNil())
            let task = sessionMock.createdTasks.first!
            expect(task.request.httpMethod) == "POST"
            expect(task.request.value(forHTTPHeaderField: "Content-Type")) == "application/json"
            let hexString = encLoc.hexEncodedString()
            expect(String(data: task.bodyData!, encoding: .utf8))
                == "{\"encryptedLocation\":\"\(hexString)\"}"
        }

        it("completes with correct response") {
            sessionMock.taskResponseData = sampleResponseJSON
            var receivedResponse: CombineLocationWithTime.Response?
            var receivedError: Error?
            backend.run(encryptedLocation: encLoc) { reponse, error in
                receivedResponse = reponse
                receivedError = error
            }
            expect(receivedResponse).toEventuallyNot(beNil())
            expect(receivedResponse?.encryptedLocationTimeCodes) == sampleResponseCodes
            expect(receivedError).to(beNil())
        }

        it("completes with error if task errors") {
            sessionMock.taskError = TestError.testError
            var receivedResponse: CombineLocationWithTime.Response?
            var receivedError: AppError?
            backend.run(encryptedLocation: encLoc) { reponse, error in
                receivedResponse = reponse
                receivedError = error
            }
            expect(receivedError).toEventually(equal(
                AppError.backendProblem(error: TestError.testError)))
            expect(receivedResponse).to(beNil())
        }

        it("completes with error if server status code wrong") {
            let statusCode = 400
            sessionMock.taskResponseCode = statusCode
            var receivedResponse: CombineLocationWithTime.Response?
            var receivedError: AppError?
            backend.run(encryptedLocation: encLoc) { reponse, error in
                receivedResponse = reponse
                receivedError = error
            }
            expect(receivedError).toEventually(equal(
                AppError.backendResponseError(statusCode: statusCode)))
            expect(receivedResponse).to(beNil())
        }

        it("completes with error if server response missing") {
            var receivedResponse: CombineLocationWithTime.Response?
            var receivedError: AppError?
            backend.run(encryptedLocation: encLoc) { reponse, error in
                receivedResponse = reponse
                receivedError = error
            }
            expect(receivedError).toEventually(equal(
                AppError.backendResponseError(statusCode: 0)))
            expect(receivedResponse).to(beNil())
        }
    }
}

struct EncryptedLocationTimeCodesResponse: Codable {
    let encryptedLocationTimeCodes: [String]
}

// 8 hours, every five minutes: 8*12
let sampleResponseCodes = (0..<8*12).map { _ in GroupElement.random() }

let sampleResponse = EncryptedLocationTimeCodesResponse(
    encryptedLocationTimeCodes: sampleResponseCodes.map { $0.hexEncodedString() }
)

let sampleResponseJSON: Data = {
    let encoder = JSONEncoder()
    return try! encoder.encode(sampleResponse)
}()
