/// Based on Rob Rix's Result (https://github.com/antitypical/Result)

public enum Result<Value, Error: ErrorType> {
    case Success(Value)
    case Failure(Error)
    
    public init(value: Value) {
        self = .Success(value)
    }

    public init(error: Error) {
        self = .Failure(error)
    }
}

public extension Result {
    public func evaluate<U>(@noescape ifSuccess ifSuccess: Value -> U, @noescape ifFailure: Error -> U) -> U {
        switch self {
        case let .Success(value):
            return ifSuccess(value)
        case let .Failure(error):
            return ifFailure(error)
        }
    }
}

// MARK: Support `Optional` chain
public extension Result {
    var value: Value? {
        return evaluate(
            ifSuccess: { $0 },
            ifFailure: { _ in nil}
        )
    }
    
    var error: Error? {
        return evaluate(
            ifSuccess: { _ in nil },
            ifFailure: { $0 }
        )
    }
}

// MARK: Support do/try/catch error handling
public extension Result {
    public init(@noescape attempt: () throws -> Value) {
        do {
            self = .Success(try attempt())
        } catch {
            self = .Failure(error as! Error)
        }
    }
    
    public func attempt() throws -> Value {
        switch self {
        case let .Success(value):
            return value
        case let .Failure(error):
            throw error
        }
    }
}

// MARK: `map` and `flatMap`
public extension Result {
    public func map<U>(@noescape transform: Value -> U) -> Result<U, Error> {
        return flatMap { .Success(transform($0)) }
    }

    public func flatMap<U>(@noescape transform: Value -> Result<U, Error>) -> Result<U, Error> {
        return evaluate(
            ifSuccess: transform,
            ifFailure: Result<U, Error>.Failure
        )
    }

    public func mapError<OtherError>(@noescape transform: Error -> OtherError) -> Result<Value, OtherError> {
        return flatMapError { .Failure(transform($0)) }
    }
    
    public func flatMapError<OtherError>(@noescape transform: Error -> Result<Value, OtherError>) -> Result<Value, OtherError> {
        return evaluate(
            ifSuccess: Result<Value, OtherError>.Success,
            ifFailure: transform
        )
    }
}

// MARK: CustomStringConvertible
extension Result: CustomStringConvertible {
    public var description: String {
        return evaluate(
            ifSuccess: { value in "Success: \(value)" },
            ifFailure: { error in "Error: \(error)" }
        )
    }
}

// MARK: CustomDebugStringConvertible
extension Result: CustomDebugStringConvertible {
    public var debugDescription: String {
        return evaluate(
            ifSuccess: { value in ".Success(\(value))" },
            ifFailure: { error in ".Error(\(error))" }
        )
    }
}

public enum IgnoreError: ErrorType { }
