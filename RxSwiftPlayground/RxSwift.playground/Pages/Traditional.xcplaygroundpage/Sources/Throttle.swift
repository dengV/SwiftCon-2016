import Foundation

//: Based on [From traditional to reactive](https://koke.me/2016/04/11/from-traditional-to-reactive/)

// Live code begin

public class Throttle<T> {
    let timeout: Double
    let callback: T -> Void
    
    public var condition: (T -> Bool)?
    
    var value: T?
    var timer: NSTimer?
    
    public init(timeout: Double, callback: T -> Void) {
        self.timeout = timeout
        self.callback = callback
    }
    
    deinit {
        timer?.invalidate()
    }
    
    public func cancel() {
        timer?.invalidate()
        timer = nil
        value = nil
    }
    
    public func update(newValue: T, isEqual: (T, T) -> Bool = { _,_ in false }) {
        // distinctUntilChanged
        if let oldValue = value where isEqual(oldValue, newValue) {
            return
        }
        
        cancel()
        
        value = newValue
        
        if let condition = condition where condition(newValue) {
            resetTimer()
        }
    }
    
    func resetTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeout,
                        target: self,
                        selector: #selector(Throttle.fire),
                        userInfo: nil,
                        repeats: false)
    }
    
    dynamic func fire() {
        guard let value = value else { return }
        callback(value)
    }
}

// Live code end
