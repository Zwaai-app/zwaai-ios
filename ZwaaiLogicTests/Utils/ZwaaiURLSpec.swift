import Quick
import Nimble
import SwiftCheck
import XCTest
@testable import ZwaaiLogic

class ZwaaiURLProperties: XCTestCase {
    func testAll() {
        property("from and to URL yields original URL") <- forAll { (url: ArbitraryValidURL) in
            let zwaaiURL = ZwaaiURL(from: url.url)
            let generatedURL = zwaaiURL?.toURL()
            return (zwaaiURL != nil)            <?> "create zwaai url"
                ^&&^
                (generatedURL != nil)           <?> "generate url"
                ^&&^
                (generatedURL! == url.url)      <?> "generated equals original"
        }
    }
}

class ZwaaiURLSpec: QuickSpec {
    override func spec() {
        describe("invalid cases") {
            it("requires valid scheme") {
                expect(ZwaaiURL(from: URL(string: "https://example.com")!)).to(beNil())
            }

            it("requires a random") {
                let withoutRandom = "zwaai-app:"
                expect(ZwaaiURL(from: URL(string: withoutRandom)!)).to(beNil())
            }

            it("requires a type") {
                let withoutType = "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab"
                expect(ZwaaiURL(from: URL(string: withoutType)!)).to(beNil())
            }

            it("requires a valid type") {
                let invalidType = "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=invalid"
                expect(ZwaaiURL(from: URL(string: invalidType)!)).to(beNil())
            }

            it("requires a name when it is a space") {
                let withoutName = "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=space"
                expect(ZwaaiURL(from: URL(string: withoutName)!)).to(beNil())
            }

            it("requires a description when it is a space") {
                let withoutDescription = "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=space&name=foo"
                expect(ZwaaiURL(from: URL(string: withoutDescription)!)).to(beNil())
            }

            it("requires autocheckout when it is a space") {
                let withoutAutoCheckout
                    = "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=space&name=foo&description=bar"
                expect(ZwaaiURL(from: URL(string: withoutAutoCheckout)!)).to(beNil())
            }
        }

        describe("person URL") {
            var personURL: ZwaaiURL!

            beforeEach {
                personURL = ZwaaiURL(from: validPersonURL)
            }

            it("has a random") {
                expect(personURL.random) == validPersonRandom
            }

            it("has the right type") {
                expect(personURL.type) == .person
            }

            it("can generate URL") {
                expect(personURL.toURL()) == validPersonURL
            }
        }

        describe("space URL") {
            var spaceURL: ZwaaiURL!

            beforeEach {
                spaceURL = ZwaaiURL(from: validSpaceURL)
            }

            it("can has a random") {
                expect(spaceURL.random) == validSpaceRandom
            }

            it("has the right type") {
                expect(spaceURL.type.isSpace).to(beTrue())
            }

            it("has the right space") {
                expect(spaceURL.type.space?.name) == validSpace.name
                expect(spaceURL.type.space?.description) == validSpace.description
                expect(spaceURL.type.space?.autoCheckout) == validSpace.autoCheckout
            }

            it("can generate URL") {
                expect(spaceURL.toURL()) == validSpaceURL
            }
        }
    }
}

let validPersonURL = URL(string:
    "zwaai-app:?random=86d5fe975f54e246857d3133b68494ab&type=person")!
let validPersonRandom = Random(hexEncoded: "86d5fe975f54e246857d3133b68494ab")

let validSpaceURL = URL(string: "zwaai-app:?random=3816dba2ea2a7c2109ab7ac60f21de47&type=space&name=HTC33%20Atelier%205&description=All%20open%20spaces&autoCheckout=28800")! // swiftlint:disable:this line_length
let validSpaceRandom = Random(hexEncoded: "3816dba2ea2a7c2109ab7ac60f21de47")
let validSpace = CheckedInSpace(name: "HTC33 Atelier 5", description: "All open spaces", autoCheckout: 28800)