import Foundation

//: Based on [From traditional to reactive](https://koke.me/2016/04/11/from-traditional-to-reactive/)

// Live code begin

public protocol Cancelable {
    func cancel()
}

public class SwitchToLatest {
    private var latest: Cancelable?
    
    public init() { }
    
    public func switchTo(next: Cancelable) {
        if let latest = self.latest {
            latest.cancel()
        }
        latest = next
    }
    
    deinit {
        latest?.cancel()
    }
}

// Live code end