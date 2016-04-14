//: Please build the scheme 'RxSwiftPlayground' first
import XCPlayground
import RxSwift
import RxCocoa

//: # Asynchronous Programming in Swift
//: # 异步
//: ### Guanshan Liu (刘冠杉)

//: # Guanshan Liu (刘冠杉)
//: - Senior iOS Developer at Alibaba Inc.
//: - Twitter:  [@guanshanliu](https://twitter.com/guanshanliu)
//: - Blog: [https://guanshanliu.typed.com](http://guanshanliu.typed.com)
//: - Organizer of [CocoaHeads Shanghai Meetup](http://www.meetup.com/CocoaHeads-Shanghai/)

//: # 异步
//: ### Asynchronous

//: # From 
//: > Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.
//:
//: [Swift Thread Safety](https://github.com/apple/swift/blob/master/docs/proposals/Concurrency.rst)

//: # 活在当下
//: ### Live in the present

//: ### I know
//: # Grand Central Dispatch
//: ### GCD for short, A low-level C API

//: ### *有人想* Someone may think
//: # Asynchronous Programming with is *easy*

let mainQueue = dispatch_get_main_queue()
let utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)

dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
    })
}

//: # The Callback Hell *地狱*

dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
        dispatch_async(utilityQueue) {
            // Cache image
        }
    })
}

//: # The Callback Hell *地狱*
//: - Difficult to read
//: - Difficult to maintain
//: - Synchronization is painful

//: # What is hard in asynchronous programming?

//: # 同步
//: ### Synchronization

// Example from [Justin Spahr-Summers](https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a)

// Bad solution
let firstQueue = dispatch_queue_create("first", DISPATCH_QUEUE_CONCURRENT)
let secondQueue = dispatch_queue_create("second", DISPATCH_QUEUE_CONCURRENT)

dispatch_async(firstQueue) {
    dispatch_sync(secondQueue) {
        // Code requiring both queues, may risk dead-lock
    }
}

// Good solution
let concurrentQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT)
dispatch_set_target_queue(firstQueue, concurrentQueue)
dispatch_set_target_queue(secondQueue, concurrentQueue)
dispatch_barrier_async(concurrentQueue) {
    // Code requiring both queues
}

//: # Asynchronous Programming is *NOT* easy
//: ## *不简单*

