import Swift

// swiftlint:disable identifier_name

infix operator • : FunctionArrowPrecedence

/// Right-to-left function composition.
/// Hint: the character is Option-8 on many keyboards.
///
/// - Parameters:
///   - f: function from B to C
///         - Parameters:
///                      - B: bla
///   - g: function from A to B
/// - Returns: function from A to C, where `f•g(a)` is the same as `f(g(a))`
func •<A, B, C>(f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
    return { (a: A) -> C in
        f(g(a))
    }
}

/// Right-to-left function composition. Variant that starts with a function without input.
/// Hint: the character is Option-8 on many keyboards.
///
/// - Parameters:
///   - f: function from B to C
///   - g: function from A to B
/// - Returns: function from A to C, where `f•g(a)` is the same as `f(g(a))`
func •<B, C>(f: @escaping (B) -> C, g: @escaping () -> B) -> () -> C {
    return { () -> C in
        f(g())
    }
}

/// Creates an array by calling a function a number of times.
///
/// - Parameters:
///   - times: how many times the function is called
///   - f: the function that generate the array elements
/// - Returns: an array containing `times` elements, created by calling `f` for each one
func iterate<A>(_ times: UInt, _ f: () -> A) -> [A] {
    return (0 ..< times).map { _ in
        f()
    }
}

/// Creates an array by calling a function a number of times.
///
/// - Parameter times: how many times the function is called
/// - Returns: curried version of `iterate<A>(Int, ()->A)`
func iterate<A>(_ times: UInt) -> (() -> A) -> [A] {
    return { (f: () -> A) -> [A] in
       iterate(times, f)
    }
}
