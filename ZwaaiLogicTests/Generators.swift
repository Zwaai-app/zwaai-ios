import Foundation
import SwiftCheck
@testable import ZwaaiLogic
import UserNotifications
import Clibsodium

extension ZwaaiType: Arbitrary {
    public static var arbitrary: Gen<ZwaaiType> {
        .frequency([
            (1, Random.arbitrary.map { .person(random: $0 )}),
            (9, CheckedInSpace.arbitrary.map { ZwaaiType.space(space: $0) })
        ])
    }
}

extension CheckedInSpace: Arbitrary {
    public static var arbitrary: Gen<CheckedInSpace> {
        let genWithoutAutoCheckout = Gen<CheckedInSpace>.compose { builder in
            CheckedInSpace(
                name: builder.generate(),
                locationCode: builder.generate(),
                description: builder.generate(),
                autoCheckout: nil,
                deadline: nil,
                locationTimeCodes: [])
        }

        let genWithAutoCheckout = Gen<(String, GroupElement, String, Int?, Date, [GroupElement])>
            .zip(String.arbitrary,
                 GroupElement.arbitrary,
                 String.arbitrary,
                 Int.arbitrary.map { $0 <= 0 ? .none : .some($0) },
                 Date.arbitrary,
                 .pure([]))
            .map(CheckedInSpace.init(name:locationCode:description:autoCheckout:deadline:locationTimeCodes:))

        return Gen<CheckedInSpace>.frequency([
            (1, genWithoutAutoCheckout),
            (9, genWithAutoCheckout)
        ])
    }
}

extension ZwaaiState: Arbitrary {
    public static var arbitrary: Gen<ZwaaiState> {
        let nonNilGen = ActionStatus<CheckedInSpace>.arbitrary.map(ZwaaiState.init(checkedInStatus:))
        return Gen<ZwaaiState>.frequency([
            (1, nonNilGen),
            (1, .pure(ZwaaiState(checkedInStatus: nil)))
        ])
    }
}

extension Date: Arbitrary {
    public static var arbitrary: Gen<Date> {
        return TimeInterval.arbitrary.map(Date.init(timeIntervalSinceNow:))
    }
}

extension AppState: Arbitrary {
    public static var arbitrary: Gen<AppState> {
        return Gen.compose { composer in
            return AppState(
                history: composer.generate(),
                zwaai: composer.generate(),
                settings: composer.generate(),
                meta: composer.generate())
        }
    }
}

extension HistoryState: Arbitrary {
    public static var arbitrary: Gen<HistoryState> {
        return Gen.compose { composer in
            let entries: [HistoryItem] = composer.generate()
            let allTimePersonZwaaiCount: UInt = composer.generate(
                using: UInt.arbitrary.suchThat { $0 <= entries.count })
            let allTimeSpaceZwaaiCount: UInt = composer.generate(
                using: UInt.arbitrary.suchThat {
                $0 + allTimePersonZwaaiCount == entries.count
            })
            return HistoryState(
                lock: composer.generate(),
                entries: entries,
                allTimePersonZwaaiCount: allTimePersonZwaaiCount,
                allTimeSpaceZwaaiCount: allTimeSpaceZwaaiCount,
                pruneLog: []
            )
        }
    }
}

extension LockState: Arbitrary {
    public static var arbitrary: Gen<LockState> {
        return .frequency([
            (1, .pure(.locked)),
            (1, .pure(.unlocking)),
            (1, .pure(.unlocked))
        ])
    }
}

extension HistoryItem: Arbitrary {
    public static var arbitrary: Gen<HistoryItem> {
        return Gen.compose { composer in
            HistoryItem(
                id: composer.generate(),
                timestamp: composer.generate(),
                type: composer.generate()
            )
        }
    }
}

extension SettingsState: Arbitrary {
    public static var arbitrary: Gen<SettingsState> {
        NotificationPermission.arbitrary.map(SettingsState.init(notificationPermission:))
    }
}
extension NotificationPermission: ArbitraryEnum {}

extension UNAuthorizationStatus: Arbitrary {
    public static var arbitrary: Gen<UNAuthorizationStatus> {
        .frequency([
            (1, .pure(.notDetermined)),
            (1, .pure(.authorized)),
            (1, .pure(.denied)),
            (1, .pure(.provisional))
        ])
    }
}

extension AppMetaState: Arbitrary {
    public static var arbitrary: Gen<AppMetaState> {
        let lastSavedGen = Gen<Result<Date, AppError>?>.frequency([
            (1, Date.arbitrary.map { .success($0) }),
            (1, .pure(.failure(.decodeFailure(error: TestError.testError )))),
            (1, .pure(nil))
        ])
        return Gen<(Result<Date, AppError>?, UNAuthorizationStatus?)>
            .zip(lastSavedGen, UNAuthorizationStatus?.arbitrary)
            .map { AppMetaState(lastSaved: $0.0, systemNotificationPermission: $0.1) }
    }
}

extension UUID: Arbitrary {
    public static var arbitrary: Gen<UUID> {
        return Gen.compose { composer in
            var bytes = (0..<16).map { _ in composer.generate(using: UInt8.arbitrary) }
            bytes[7] = bytes[7] | 0b01000000 // UUID version 4
            bytes[9] = bytes[9] | 0b01000000 // clock_seq_hi_and_reserved

            let part1 = Data(bytes[0..<4]).hexEncodedString()
            let part2 = Data(bytes[4..<6]).hexEncodedString()
            let part3 = Data(bytes[6..<8]).hexEncodedString()
            let part4 = Data(bytes[8..<10]).hexEncodedString()
            let part5 = Data(bytes[10..<16]).hexEncodedString()

            return UUID(uuidString: part1 + "-" + part2 + "-" + part3 + "-" + part4 + "-" + part5)!
        }
    }
}

extension URL: Arbitrary {
    public static var arbitrary: Gen<URL> {
        let anyUrlGenerator = String.arbitrary
            .map { URL(string: $0) }
            .suchThat { $0 != nil }
            .map { $0! }

        return .frequency([
            (1, anyUrlGenerator),
            (1, ArbitraryPersonURL.arbitrary.map { $0.url }),
            (1, ArbitrarySpaceURL.arbitrary.map { $0.url })
        ])
    }
}

extension ZwaaiURL: Arbitrary {
    public static var arbitrary: Gen<ZwaaiURL> {
        ArbitraryValidURL.arbitrary
            .map { ZwaaiURL(from: $0.url)! }
    }
}

public struct ArbitraryValidURL: Arbitrary {
    let url: URL
    init(url: URL) { self.url = url }

    public static var arbitrary: Gen<ArbitraryValidURL> {
        Gen<URL>
            .frequency([
                (1, ArbitraryPersonURL.arbitrary.map { $0.url }),
                (1, ArbitrarySpaceURL.arbitrary.map { $0.url })
            ])
            .map(ArbitraryValidURL.init(url:))
    }
}

public struct ArbitraryPersonURL: Arbitrary {
    let url: URL
    init(url: URL) { self.url = url }

    public static var arbitrary: Gen<ArbitraryPersonURL> {
        let toURLString: (Random) -> String
            = { "zwaai-app:?type=person&random=\($0.hexEncodedString())" }
        let toURL: (String) -> URL = { URL(string: $0)! }

        return Random.arbitrary
            .map(ArbitraryPersonURL.init(url:) • toURL • toURLString)
    }
}

public struct ArbitrarySpaceURL: Arbitrary {
    let url: URL
    init(url: URL) { self.url = url }

    public static var arbitrary: Gen<ArbitrarySpaceURL> {
        return CheckedInSpace.arbitrary.map { space in
            var urlComponents = URLComponents()
            urlComponents.scheme = "zwaai-app"
            urlComponents.queryItems = [
                URLQueryItem(name: "type", value: "space")
            ] + space.toQueryItems()
             return ArbitrarySpaceURL(url: urlComponents.url!)
        }
    }
}

extension AppError: Arbitrary {
    public static var arbitrary: Gen<AppError> {
        return .frequency([
            (1, .pure(.noUserDocumentsDirectory)),
            (1, .pure(.decodeFailure(error: TestError.testError))),
            (1, .pure(.encodeFailure(error: TestError.testError))),
            (1, String.arbitrary.map { AppError.invalidZwaaiType(type: $0) }),
            (1, .pure(.backendProblem(error: TestError.testError))),
            (1, Int.arbitrary
                .suchThat { $0 >= 300 && $0 <= 599 }
                .map { .backendResponseError(statusCode: $0)})
        ])
    }
}

extension AppAction: ArbitraryEnum {}
extension HistoryAction: ArbitraryEnum {}
extension ZwaaiAction: ArbitraryEnum {}
extension SettingsAction: ArbitraryEnum {}

extension ActionStatus: Arbitrary where SuccessValue == CheckedInSpace {
    public static var arbitrary: Gen<ActionStatus<CheckedInSpace>> {
        .frequency([
            (1, .pure(.pending)),
            (1, CheckedInSpace.arbitrary.map { .succeeded(value: $0) }),
            (1, String.arbitrary.map { .failed(reason: $0) })
        ])
    }
}

extension AppMetaAction: Arbitrary {
    public static var arbitrary: Gen<AppMetaAction> {
        return .frequency([
            (1, Result<Date, AppError>.arbitrary.map { AppMetaAction.didSaveState(result: ($0)) }),
            (1, .pure(AppMetaAction.zwaaiSucceeded(url: ZwaaiURL.arbitrary.generate,
                                                   presentingController: UIViewController(), onDismiss: {}))),
            (1, .pure(AppMetaAction.zwaaiFailed(presentingController: UIViewController(), onDismiss: {}))),
            (1, .pure(AppMetaAction.setupAutoCheckout))
        ])
    }
}

let pregeneratedGroupElements = [
    "1a9c3a05b6dd2c56e63e356b3aa4da10f5c5411320021581774741868b1b0d08",
    "a89979dc4bd2117784e9e503fece9850573ae4181a54bfcee756699dc30a8e7f",
    "f2cbb6c347c9543afd29861ea0b9bcd1dfff76254e473744693b80b1fdfe7543",
    "f0a3057a6f0627ae2a14e29862d44d69351ae428f2b1c691c975f87fca09c54a",
    "e40124bf34eb1ad63064b83d16f2b331aaa38844d977186610b84c5a06368241",
    "580ff1df3237ed4c52cd4df05a47b2dab98b5158fe6c5e7ec40f177feec68d3e",
    "209e398b0d2fd49fe36edf3cf932339642fc766c3c7af632499eb9b809e06747",
    "0e68d2051f1ffcd338b8629b32ed43680d127957a2ce5480e3dc8cd40eb9a86e",
    "480da2c53b41abea6467b983647ddf0f5cfd8fb0286ed00be8cee275e01c5d48",
    "ce4744a3c5df2729ec7b8e1f682522f7724aeea734aa59f29e0046069d18df65"
].map { GroupElement(hexEncoded: $0)! }

extension GroupElement: Arbitrary {
    public static var arbitrary: Gen<GroupElement> {
        .fromElements(of: pregeneratedGroupElements)
    }
}

// MARK: - Check for UUIDs

import XCTest

class UUIDGeneratorTest: XCTestCase {
    func testAll() {
        property("generates valid UUIDs") <- forAll { (_: UUID) in
            return true
        }
    }
}
