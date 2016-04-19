import Foundation

//: Based on [From traditional to reactive](https://koke.me/2016/04/11/from-traditional-to-reactive/)

// Live code begin

public protocol Cancelable {
    func cancel()
}

public class SwitchToLatest {
    public var latest: Cancelable? {
        willSet {
            latest?.cancel()
        }
    }
    
    public init() { }
    
    deinit {
        latest?.cancel()
    }
}

// Live code end