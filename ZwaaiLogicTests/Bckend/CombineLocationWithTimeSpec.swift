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
            backend.run(encryptedLocation: encLoc) { _ in }
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
            var receivedResult: Result<[GroupElement], AppError>?
            backend.run(encryptedLocation: encLoc) { result in
                receivedResult = result
            }
            expect(receivedResult).toEventuallyNot(beNil())
            expect(try! receivedResult?.get()) == sampleResponseCodes
        }

        it("completes with error if task errors") {
            sessionMock.taskError = TestError.testError
            var receivedResult: Result<[GroupElement], AppError>?
            backend.run(encryptedLocation: encLoc) { result in
                receivedResult = result
            }
            expect(receivedResult).toEventuallyNot(beNil())
            expect(receivedResult) ==
                .failure(AppError.backendProblem(error: TestError.testError))
        }

        it("completes with error if server status code wrong") {
            let statusCode = 400
            sessionMock.taskResponseCode = statusCode
            var receivedResult: Result<[GroupElement], AppError>?
            backend.run(encryptedLocation: encLoc) { result in
                receivedResult = result
            }
            expect(receivedResult).toEventuallyNot(beNil())
            expect(receivedResult)
                == .failure(AppError.backendResponseError(statusCode: statusCode))
        }

        it("completes with error if server response missing") {
            var receivedResult: Result<[GroupElement], AppError>?
            backend.run(encryptedLocation: encLoc) { result in
                receivedResult = result
            }
            expect(receivedResult).toEventuallyNot(beNil())
            expect(receivedResult)
                == .failure(AppError.backendResponseError(statusCode: 0))
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
