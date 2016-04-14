//: [Previous](@previous) | [Introduction](Introduction)

import Foundation

/*:
 # From 
 
 > Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.
 
 [Swift Thread Safety](https://github.com/apple/swift/blob/master/docs/proposals/Concurrency.rst)
 
 ---
 
 # 活在当下
 ### Live in the present
 
 ---
 
 # 自生自灭
 ### We are on our own
 
 ---
 
 # Grand Central Dispatch
 ### GCD for short, A low-level C API
 
 ---
 
 # `NSOperation` & `NSOperationQueue`
 ### An Objective-C API on top of Grand Central Dispatch
 
 ---
 
 # Grand Central Dispatch
 
 ---
 
 ### *有人想* Someone may think
 # Asynchronous Programming with GCD is *easy*
 
 */

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

/*:
 # The Callback Hell *地狱*
 
 - Difficult to read
 - Difficult to maintain
 - Synchronization is painful
 
 ---
 
 # What is hard in asynchronous programming?
 
 ---
 
 # 问题1: 同步
 ## Synchronization
 
 */

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

/*:
 # `NSOperation` & `NSOperationQueue`
 
 ---
 
 # `NSOperation` & `NSOperationQueue`
 
 - 依赖 Dependencies
 - 状态监控 Observe the state using KVO
 - 控制 More Controls: `maxConcurrentOperationCount`
 
 ---
 
 # 问题2: 错误处理
 ## Errors handling in asynchronous scenarios
 
 ---
 
 # Now 现状
 
 1. Apple uses completion handlers to handle errors in asynchronous scenarios.
 2. Apple's use of completion handlers is they are **always** called.
 3. Completion handlers are called either with a result or an error.
 
 ---
 
 # Now 现状
 
 1. No guarantee that an asynchronous function always calls a callback
 2. No guarantee that an asynchronous function only calls a callback once
 3. Do not know on which queue that a callback will be called
 
 ---
 
 # 问题3: 状态孤立
 ## State isolation
 
 ---
 
 > I agree strongly with reactive proponents who say that the current standard ways of writing apps are broken. Too much state, for sure, and not enough ways to specify flow.
 The less state we have to manage, and the more declarative code we can write, the better.
 - Brent Simmons in [Reactive Followup](http://inessential.com/2016/04/10/reactive_followup)
 
 ---
 
 # 3rd-party frameworks
 
 1. [BrightFuture](https://github.com/Thomvis/BrightFutures)
 2. [RxSwift](https://github.com/ReactiveX/RxSwift)
 3. [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
 
 ---
 
 # There’s no silver bullet.
 
 ---
 
 # There are good practicals.
 */

//: [Next](@next) | [Introduction](Introduction)
