import Foundation
import SwiftCheck
import XCTest
import Quick
import Nimble
@testable import ZwaaiLogic

class SpyingLoadSaveDeps: LoadSaveDeps {
    var loadSaveDeps: LoadSaveDeps!
    var writtenData: Data?
    var writtenToURL: URL?
    var writtenWithOptions: Data.WritingOptions?

    override init() {
        super.init()
        fileManager = FileManagerSpy(
            fileExists: true,
            urls: [.documentDirectory: URL(string: "file:///tmp")!])
        loadContentsOf = { url in
            guard let writtenUrl = self.writtenToURL,
                let data = self.writtenData,
                writtenUrl == url else {
                throw TestError.testError
            }
            return data
        }
        writeData = { data, url, options in
            self.writtenData = data
            self.writtenToURL = url
            self.writtenWithOptions = options
        }
    }
}

class LoadSaveStateProperties: XCTestCase {
    func testAll() {
        property("save and load returns original state") <- forAll { (appState: AppState) in
            var stateWithoutMeta = appState
            stateWithoutMeta.meta = AppMetaState()

            let spy = SpyingLoadSaveDeps()
            let result = saveAppState(state: stateWithoutMeta, deps: spy)
            expect(abs(try result.get().timeIntervalSinceNow)) < 5
            expect(spy.writtenWithOptions).to(contain(.atomic))
            expect(spy.writtenWithOptions).to(contain(.completeFileProtection))

            let loadedState = loadAppState(deps: spy)
            return try loadedState.get() == stateWithoutMeta
        }
    }
}

class LoadSaveStateSpec: QuickSpec {
    override func spec() {
        describe("load") {
            it("return initial state when file doesn't exist") {
                let deps = LoadSaveDeps()
                deps.fileManager = FileManagerSpy(
                    fileExists: false,
                    urls: [.documentDirectory: URL(string: "file:///tmp")!]
                )
                let result = loadAppState(deps: deps)
                expect(try result.get()) == initialAppState
            }

            it("returns error on decode problem") {
                let spy = SpyingLoadSaveDeps()
                let state = initialAppState
                _ = saveAppState(state: state, deps: spy)
                spy.writtenData = spy.writtenData!.prefix(spy.writtenData!.count/2)
                let result = loadAppState(deps: spy)
                switch result {
                case .success: fail("should have failed decoding")
                case .failure(let error): expect(error.isDecodeStateFailure).to(beTrue())
                }
            }

            it("fails when there is no documents directory") {
                let deps = LoadSaveDeps()
                deps.fileManager = FileManagerSpy()
                let result = loadAppState(deps: deps)
                switch result {
                case .success: fail("should have failed")
                case .failure(let error): expect(error).to(matchError(AppError.noUserDocumentsDirectory))
                }
            }
        }

        describe("save") {
            it("returns error on write failure") {
                let spy = SpyingLoadSaveDeps()
                spy.writeData = { _, _, _ in throw TestError.testError }
                let state = initialAppState
                let result = saveAppState(state: state, deps: spy)
                switch result {
                case .success: fail("should have failed saving")
                case .failure(let error):
                    expect(error.isEncodeStateFailure).to(beTrue())
                    expect(error.encodeStateFailure).to(matchError(TestError.testError))
                }
            }
        }
    }
}
