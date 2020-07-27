import Clibsodium

// swiftlint:disable identifier_name
// swiftlint:disable large_tuple

public struct Scalar: Equatable {
    let value: [UInt8]
    var count: Int { return value.count }

    public static func random() -> Scalar {
        var r = newBuffer()
        crypto_core_ristretto255_scalar_random(&r)
        return Scalar(value: r)
    }

    static func newBuffer() -> [UInt8] {
        return [UInt8](repeating: 0, count: size)
    }

    static let size: Int = Int(crypto_core_ristretto255_SCALARBYTES)
}

public struct GroupElement: Equatable {
    let value: [UInt8]
    var count: Int { return value.count }

    public static func random() -> GroupElement {
        var r = newBuffer()
        crypto_core_ristretto255_random(&r)
        return GroupElement(value: r)
    }

    static func newBuffer() -> [UInt8] {
        return [UInt8](repeating: 0, count: size)
    }

    static let size: Int = Int(crypto_core_ristretto255_BYTES)
}

public func * (lhs: Scalar, rhs: GroupElement) -> GroupElement {
    var result = GroupElement.newBuffer()
    var lhsValue = lhs.value
    var rhsValue = rhs.value
    let err = crypto_scalarmult_ristretto255(&result, &lhsValue, &rhsValue)
    assert(err == 0)
    return GroupElement(value: result)
}

public func / (lhs: GroupElement, rhs: Scalar) -> GroupElement {
    var rhsValue = rhs.value
    var rhsInverted = Scalar.newBuffer()
    let err = crypto_core_ristretto255_scalar_invert(&rhsInverted, &rhsValue)
    assert(err == 0)

    return Scalar(value: rhsInverted) * lhs
}

public func singleRound() -> (l: GroupElement, lt: GroupElement, t: Scalar) {
    /// Client scans location code `l` and combines it with random `r`
    let r = Scalar.random()
    let l = GroupElement.random()
    let lr = r * l

    /// Server combines it with time code `t`
    let t = Scalar.random()
    let lrt = t * lr

    /// Client removes random `r` and stores `lt`
    let lt = lrt / r

    return (l, lt, t)
}
