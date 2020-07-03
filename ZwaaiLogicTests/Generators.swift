import Foundation
import SwiftCheck
@testable import ZwaaiLogic

extension HistoryZwaaiType: Arbitrary {
    public static var arbitrary: Gen<HistoryZwaaiType> {
        Gen<HistoryZwaaiType>.frequency([
            (1, .pure(.person)),
            (9, CheckedInSpace.arbitrary.map { HistoryZwaaiType.space(space: $0) })
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

enum TestError: Error { case testError }

extension AppMetaState: Arbitrary {
    public static var arbitrary: Gen<AppMetaState> {
        return .frequency([
            (1, Date.arbitrary.map { AppMetaState.init(lastSaved: .success($0)) }),
            (1, .pure(AppMetaState(lastSaved: .failure(.decodeStateFailure(error: TestError.testError ))))),
            (1, .pure(AppMetaState(lastSaved: nil)))
        ])
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

        let validZwaaiUrlGenerator = Random.arbitrary
            .map { "zwaai-app://?random=\($0.hexEncodedString())&type=person" }
            .map { URL(string: $0)! }

        return .frequency([
            (1, anyUrlGenerator),
            (1, validZwaaiUrlGenerator)
        ])
    }
}

extension AppError: Arbitrary {
    public static var arbitrary: Gen<AppError> {
        return .frequency([
            (1, .pure(.noUserDocumentsDirectory)),
            (1, .pure(.decodeStateFailure(error: TestError.testError))),
            (1, .pure(.encodeStateFailure(error: TestError.testError))),
            (1, String.arbitrary.map { AppError.invalidHistoryZwaaiType(type: $0) })
        ])
    }
}

protocol ArbitraryEnum {}
extension AppAction: ArbitraryEnum {}
extension HistoryAction: ArbitraryEnum {}
extension ZwaaiAction: ArbitraryEnum {}
extension AppMetaAction: ArbitraryEnum {}

import XCTest

class UUIDGeneratorTest: XCTestCase {
    func testAll() {
        property("generates valid UUIDs") <- forAll { (_: UUID) in
            return true
        }
    }
}
