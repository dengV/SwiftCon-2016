
public enum Event<T> {
    case Next(T)
    case Error(ErrorType)
    case Completed
}

public extension Event {
    public func map<U>(@noescape f: T -> U) -> Event<U> {
        switch self {
        case let .Next(value):
            return .Next(f(value))
        case let .Error(error):
            return .Error(error)
        case .Completed:
            return .Completed
        }
    }
}

public extension Event {
    public var element: T? {
        if case .Next(let value) = self {
            return value
        }
        return nil
    }
    
    public var error: ErrorType? {
        if case .Error(let error) = self {
            return error
        }
        return nil
    }
}

extension Event: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Next(let value):
            return "Next(\(value))"
        case .Error(let error):
            return "Error(\(error))"
        case .Completed:
            return "Completed"
        }
    }
}
