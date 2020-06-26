import Foundation
import SwiftCheck
@testable import Zwaai

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

        let genWithAutoCheckout = Gen<(String, String, Int, Date)>
            .zip(String.arbitrary, String.arbitrary, Int.arbitrary, Date.arbitrary)
            .map(CheckedInSpace.init(name:description:autoCheckout:deadline:))

        return Gen<CheckedInSpace>.frequency([
            (1, genWithoutAutoCheckout),
            (9, genWithAutoCheckout)
        ])
    }
}

extension Date: Arbitrary {
    public static var arbitrary: Gen<Date> {
        return TimeInterval.arbitrary.map(Date.init(timeIntervalSinceNow:))
    }
}
