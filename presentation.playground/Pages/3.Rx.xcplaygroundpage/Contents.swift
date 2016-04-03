//: [Previous](@previous)

import UIKit
import XCPlayground

//: Asynchronous Programming with Futures/Promises is better.
//: But not all asynchronous interactions are one-off.

//: ```
//: enum Event<Element> {
//:     case Next(Element)
//:     case Error(ErrorType)
//:     case Completed
//: }

public struct Promise<T> {
    let operation: (Event<T> -> Void) -> Void
    
    public init(operation: (Event<T> -> Void) -> Void) {
        self.operation = operation
    }
    
    public func start(completion: Event<T> -> Void) {
        operation() { event in
            completion(event)
        }
    }
    
    public func map<U>(f: T -> U) -> Promise<U> {
        return Promise<U> { completion in
            self.start { event in
                completion(event.map(f))
            }
        }
    }
}

Promise<String> { completion in
    completion(.Next("test"))
}.map { value in
    value.uppercaseString
}.start { event in
    if case let .Next(value) = event {
        value
    } else {
        // Do something else
    }
}

//: # It's a pull interaction.

//: > In the Rx world, the fundamental part is the combination of the Observer pattern and the Iterator pattern... Both, the Observer and Iterator patterns are pull interactions.
//: - [Bonto](https://twitter.com/bontoJR) in article [The Reactive Revolution of Swift](https://sideeffects.xyz/2016/the-reactive-revolution-of-swift/)

//: > For the iterator we keep getting values as long as they are available, for the observer pattern, we process the value right after the producer has sent out the notification to all the concrete observers, pulling the data out of it.
//: - [Bonto](https://twitter.com/bontoJR) in article [The Reactive Revolution of Swift](https://sideeffects.xyz/2016/the-reactive-revolution-of-swift/)

//: # Futures/Promises
//: - No more callback hell
//: - Declaration: code is easy to read and maintain

//: > Pulling is definitely a concrete and established solution and works great as long as everything is processed in the same thread. What happens when the data has to be pulled and processed asynchronously? Well, locks are starting to play a big role and things can get quite difficult really fast.
//: - [Bonto](https://twitter.com/bontoJR) in article [The Reactive Revolution of Swift](https://sideeffects.xyz/2016/the-reactive-revolution-of-swift/)

//: # Futures/Promises
//: Good:
//: - No more callback hell
//: - Declaration: code is easy to read and maintain
//: Bad:
//: - **Synchronization is still painful**

//: # Futures/Promises
//: Good:
//: - No more callback hell
//: - Declaration: code is easy to read and maintain
//: - There is a defined way how errors should be handled
//: - If subscribe once, callback will be called once only
//: Bad:
//: - **Synchronization is still painful**
//: - Do not know on which queue that a callback will be called

//: # Instead of pulling the data out of the producer, why not let the producer push it to all subscribers?

public final class Signal<T> {
    var event: Event<T>?
    var callbacks: [Event<T> -> Void] = []
    let lockQueue = dispatch_queue_create("lock_queue", DISPATCH_QUEUE_SERIAL)
    
    func notify() {
        guard let event = event else {
            return
        }
        
        callbacks.forEach { callback in
            callback(event)
        }
    }
    
    func update(event event: Event<T>) {
        dispatch_sync(lockQueue) {
            self.event = event
        }
        
        notify()
    }
    
    public func subscribe(f: Event<T> -> Void) -> Signal<T> {
        // Callback
        if let event = event {
            f(event)
        }
        
        callbacks.append(f)
        
        return self
    }
    
    public func map<U>(f: T -> U) -> Signal<U> {
        let signal = Signal<U>()
        
        subscribe { event in
            signal.update(event: event.map(f))
        }
        
        return signal
    }
}

public extension Signal {
    public func sendNext(value: T) {
        update(event: .Next(value))
    }
    
    public func sendError(error: ErrorType) {
        update(event: .Error(error))
    }
    
    public func sendCompleted() {
        update(event: .Completed)
    }
}

let signal = Signal<String>()

signal.map { value in
    value.uppercaseString
}.subscribe { event in
    if case let .Next(value) = event {
        value
    } else {
        // Do something else
    }
}

signal.sendNext("test")

//: # It's the foundation of Reactive Programming

//: # Reactive Programming in Swift
//: [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
//: [RxSwift](https://github.com/ReactiveX/RxSwift)
//: [Bond](https://github.com/SwiftBond/Bond)
//: [VinceRP](https://github.com/bvic23/VinceRP)

//: # References
//: - [Push vs Pull Signal](http://www.fantageek.com/blog/2016/01/03/push-vs-pull-signal/)
//: - [ReactiveX](http://reactivex.io)
//: - [RxMarin](http://rx-marin.com)

//: # 谢谢
//: ### Thank You

//: # 欢迎提问
//: ### Questions?

//: [Next](@next)
