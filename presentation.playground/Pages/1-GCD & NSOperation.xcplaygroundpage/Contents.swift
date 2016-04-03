import UIKit
import XCPlayground

//: # Asynchronous Programming in Swift
//: # 异步
//: ### Guanshan Liu (刘冠杉)

//: # Guanshan Liu (刘冠杉)
//: - Senior iOS Developer at Alibaba Inc.
//: - Twitter:  [@guanshanliu](https://twitter.com/guanshanliu)
//: - Blog: [https://guanshanliu.typed.com](http://guanshanliu.typed.com)
//: - GitHub: [GaunshanLiu](https://github.com/guanshanliu)
//: - Organizer of [CocoaHeads Shanghai Meetup](http://www.meetup.com/CocoaHeads-Shanghai/)

//: # 异步
//: ### Asynchronous

//: # From 
//: > Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.
//: - [Swift Evolution](https://github.com/apple/swift-evolution)
//:
//: [Swift Thread Safety](https://github.com/apple/swift/blob/master/docs/proposals/Concurrency.rst)

//: # 活在当下
//: ### Live in the present

//: ### I know 
//: # Grand Central Dispatch
//: ### GCD for short, A low-level C API

//: # Someone might think asynchronous Programming with GCD is easy.

let mainQueue = dispatch_get_main_queue()
let utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)

dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
    })
}

//: # The Callback Hell

dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
        dispatch_async(utilityQueue) {
            // Cache image
        }
    })
}

//: # The Callback Hell
//: - Code is difficult to read
//: - Code is difficult to maintain
//: - **Synchronization becomes painful**

//: > Asynchronous programming is not just about running tasks or perform computation in a separate thread, at some point, we will need to synchronize values across threads and the most common solution is to add locks.
//: - [Bonto](https://twitter.com/bontoJR) in article [The Reactive Revolution of Swift](https://sideeffects.xyz/2016/the-reactive-revolution-of-swift/)

//: > As soon as locks are introduced, the complexity of the code raises of at least one order of magnitude and one big new component is added to the complexity equation: unpredictability.
//: - [Bonto](https://twitter.com/bontoJR) in article [The Reactive Revolution of Swift](https://sideeffects.xyz/2016/the-reactive-revolution-of-swift/)

//: # Asynchronous Programming is hard.

//: # So what is really hard in asynchronous programming? **Synchronization**.

let firstQueue = dispatch_queue_create("first", DISPATCH_QUEUE_CONCURRENT)
let secondQueue = dispatch_queue_create("second", DISPATCH_QUEUE_CONCURRENT)

dispatch_async(firstQueue) {
    dispatch_sync(secondQueue) {
        // Code requiring both queues
    }
}

//: # You might risk a deadlock.

// Example from [Justin Spahr-Summers](https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a)

let concurrentQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT)
dispatch_set_target_queue(firstQueue, concurrentQueue)
dispatch_set_target_queue(secondQueue, concurrentQueue)
dispatch_barrier_async(concurrentQueue) {
    // Code requiring both queues
}

//: # How errors should be handled in asynchronous scenarios?
//: - No guarantee that an asynchronous function always calls a callback
//: - No guarantee that an asynchronous function only calls a callback once
//: - Do not know on which queue that a callback will be called

//: # Asynchronous Programming with GCD is *NOT* easy.

//: # `NSOperation` and `NSOperationQueue`
//: ### An Objective-C API on top of Grand Central Dispatch
//: - 依赖 Dependencies
//: - 状态监控 Observe the state using KVO
//: - 控制 More Controls, for example, `maxConcurrentOperationCount`

//: # 一样不简单
//: ### But, creating an `NSOperation` subclass is not trivial.
//: You have to take control of the life-cycle of the `NSOperation`.
//: - Checking `cancelled`
//: - Sometimes, taking care of `finished`

//: # References
//: - Bart Jacobs's [Choosing Between NSOperation and Grand Central Dispatch](http://bartjacobs.com/choosing-between-nsoperation-and-grand-central-dispatch/)
//: - Marcus Zarra's [A Modern Network Operation](http://www.cimgf.com/2016/01/28/a-modern-network-operation/)

//: [Next](@next)
