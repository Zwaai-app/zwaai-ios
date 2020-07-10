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
public func •<A, B, C>(f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
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
public func •<B, C>(f: @escaping (B) -> C, g: @escaping () -> B) -> () -> C {
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
public func iterate<A>(_ times: UInt, _ f: () -> A) -> [A] {
    return (0 ..< times).map { _ in
        f()
    }
}

/// Creates an array by calling a function a number of times.
///
/// - Parameter times: how many times the function is called
/// - Returns: curried version of `iterate<A>(Int, ()->A)`
public func iterate<A>(_ times: UInt) -> (() -> A) -> [A] {
    return { (f: () -> A) -> [A] in
       iterate(times, f)
    }
}

/// A helper function that takes one parameter and does nothing, to easier
/// communicate intent in code.
///
/// - Parameter t: ignored
public func ignore<T>(_ t: T) { }

/// A helper function used for type lifting somthing that is of type `Never`
/// into an actual type. This is just for the compiler, it will of course never be actually called.
///
/// - Parameter never: anything of type `Never`
/// - Returns: something of the desired type
///
/// An example of using this is with *SwiftRex middleware*.
/// A SwiftRex middleware has three associated types, one of which is its output action type.
/// A middleware that only consumes actions, and doesn't produce them itself (e.g. a logging
/// middleware) has `Never` as its output action type. When you lift that middleware to combine
/// it with other middlewares, you can use `absurd` as the output action map, so that the
/// lifted middleware ends up having the correct type:
///
/// `let liftedLoggerMiddleware: AnyMiddleware<AppAction, AppAction, AppState>`
/// `    = loggerMiddleware.lift(outputActionMap: absurd).eraseToAnyMiddleware()`
public func absurd<A>(_ never: Never) -> A {}
