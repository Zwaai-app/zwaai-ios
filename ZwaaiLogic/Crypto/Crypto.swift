import Clibsodium

// swiftlint:disable identifier_name
// swiftlint:disable large_tuple

struct Scalar: Equatable {
    let value: [UInt8]

    static func random() -> Scalar {
        var r = newBuffer()
        crypto_core_ristretto255_scalar_random(&r)
        return Scalar(value: r)
    }

    private static func newBuffer() -> [UInt8] {
        return [UInt8](repeating: 0, count: Int(crypto_core_ristretto255_SCALARBYTES))
    }
}

struct GroupElement: Equatable {
    let value: [UInt8]

    static func random() -> GroupElement {
        var r = newBuffer()
        crypto_core_ristretto255_random(&r)
        return GroupElement(value: r)
    }

    private static func newBuffer() -> [UInt8] {
        return [UInt8](repeating: 0, count: Int(crypto_core_ristretto255_BYTES))
    }
}

func * (lhs: Scalar, rhs: GroupElement) -> GroupElement {
    var result = [UInt8](repeating: 0, count: Int(crypto_core_ristretto255_BYTES))
    var lhsValue = lhs.value
    var rhsValue = rhs.value
    let err = crypto_scalarmult_ristretto255(&result, &lhsValue, &rhsValue)
    assert(err == 0)
    return GroupElement(value: result)
}

func / (lhs: GroupElement, rhs: Scalar) -> GroupElement {
    var rhsValue = rhs.value
    var rhsInverted = [UInt8](repeating: 0, count: Int(crypto_core_ristretto255_SCALARBYTES))
    let err = crypto_core_ristretto255_scalar_invert(&rhsInverted, &rhsValue)
    assert(err == 0)

    return Scalar(value: rhsInverted) * lhs
}

func singleRound() -> (l: GroupElement, lt: GroupElement, t: Scalar) {
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
