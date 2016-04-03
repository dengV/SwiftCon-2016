import Foundation

public final class Future<Value, Error: ErrorType> {
    public typealias ResultType = Result<Value, Error>
    
    private var result: ResultType?
    private var operation: (ResultType -> Void) -> Void
    
    public init(_ operation: (ResultType -> Void) -> Void) {
        self.operation = operation
    }
    
    private func onCompletion(completion: ResultType -> Void) -> Self {
        if let result = result {
            completion(result)
            return self
        }
        
        operation { [weak self] result in
            self?.result = result
            completion(result)
        }
        return self
    }
    
    public func onSuccess(completion: Value -> Void) -> Self {
        return onCompletion { result in
            if case let .Success(value) = result {
                completion(value)
            }
        }
    }
    
    public func onFailure(completion: Error -> Void) -> Self {
        return onCompletion { result in
            if case let .Failure(error) = result {
                completion(error)
            }
        }
    }
}

public extension Future {
    public func map<U>(transform: Value -> U) -> Future<U, Error> {
        return Future<U, Error> { completion in
            self.onCompletion { result in
                switch result {
                    case .Success(let value): completion(.Success(transform(value)))
                    case .Failure(let error): completion(.Failure(error))
                }
            }
        }
    }
}

public extension Future {
    public convenience init(result: ResultType) {
        self.init { completion in
            completion(result)
        }
    }
    
    public convenience init(value: Value) {
        self.init(result: .Success(value))
    }
    
    public convenience init(error: Error) {
        self.init(result: .Failure(error))
    }
}
