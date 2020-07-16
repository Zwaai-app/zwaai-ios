import Foundation
import SwiftCheck
@testable import ZwaaiLogic
import UserNotifications

extension ZwaaiType: Arbitrary {
    public static var arbitrary: Gen<ZwaaiType> {
        .frequency([
            (1, .pure(.person)),
            (9, CheckedInSpace.arbitrary.map { ZwaaiType.space(space: $0) })
        ])
    }
}

extension CheckedInSpace: Arbitrary {
    public static var arbitrary: Gen<CheckedInSpace> {
        let genWithoutAutoCheckout = Gen<CheckedInSpace>.compose { builder in
            CheckedInSpace(
                name: builder.generate(),
                description: builder.generate(),
                autoCheckout: nil,
                deadline: nil)
        }

        let genWithAutoCheckout = Gen<(String, String, Int?, Date)>
            .zip(String.arbitrary,
                 String.arbitrary,
                 Int.arbitrary.map { $0 <= 0 ? .none : .some($0) },
                 Date.arbitrary)
            .map(CheckedInSpace.init(name:description:autoCheckout:deadline:))

        return Gen<CheckedInSpace>.frequency([
            (1, genWithoutAutoCheckout),
            (9, genWithAutoCheckout)
        ])
    }
}

extension ZwaaiState: Arbitrary {
    public static var arbitrary: Gen<ZwaaiState> {
        return Gen<ZwaaiState>.frequency([
            (1, CheckedInSpace.arbitrary.map(ZwaaiState.init(checkedIn:))),
            (1, .pure(ZwaaiState(checkedIn: nil)))
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
                type: composer.generate(),
                random: composer.generate()
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
            (1, .pure(.failure(.decodeStateFailure(error: TestError.testError )))),
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
            = { "zwaai-app:?random=\($0.hexEncodedString())&type=person" }
        let toURL: (String) -> URL = { URL(string: $0)! }

        return Random.arbitrary
            .map(ArbitraryPersonURL.init(url:) • toURL • toURLString)
    }
}

public struct ArbitrarySpaceURL: Arbitrary {
    let url: URL
    init(url: URL) { self.url = url }

    public static var arbitrary: Gen<ArbitrarySpaceURL> {
        return Gen<(Random, CheckedInSpace)>
            .zip(Random.arbitrary, CheckedInSpace.arbitrary)
            .map { (random: Random, space: CheckedInSpace) in
                var urlComponents = URLComponents()
                urlComponents.scheme = "zwaai-app"
                urlComponents.queryItems = [
                    URLQueryItem(name: "random", value: random.hexEncodedString()),
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
            (1, .pure(.decodeStateFailure(error: TestError.testError))),
            (1, .pure(.encodeStateFailure(error: TestError.testError))),
            (1, String.arbitrary.map { AppError.invalidZwaaiType(type: $0) })
        ])
    }
}

extension AppAction: ArbitraryEnum {}
extension HistoryAction: ArbitraryEnum {}
extension ZwaaiAction: ArbitraryEnum {}
extension SettingsAction: ArbitraryEnum {}

extension AppMetaAction: Arbitrary {
    public static var arbitrary: Gen<AppMetaAction> {
        return .frequency([
            (1, Result<Date, AppError>.arbitrary.map { AppMetaAction.didSaveState(result: ($0)) }),
            (1, .pure(AppMetaAction.zwaaiSucceeded(presentingController: UIViewController(), onDismiss: {}))),
            (1, .pure(AppMetaAction.zwaaiFailed(presentingController: UIViewController(), onDismiss: {}))),
            (1, .pure(AppMetaAction.setupAutoCheckout))
        ])
    }
}

import XCTest

class UUIDGeneratorTest: XCTestCase {
    func testAll() {
        property("generates valid UUIDs") <- forAll { (_: UUID) in
            return true
        }
    }
}
