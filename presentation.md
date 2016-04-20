## [fit] Asynchronous Programming in 
## **Swift**
## 异步
#### @guanshanliu *SwiftCon China 2016*

---

# About Me

- 刘冠杉 Guanshan Liu
- Senior iOS Developer at Alibaba Music
- Twitter:  [@guanshanliu](https://twitter.com/guanshanliu)
- Medium: [@guanshanliu](https://medium.com/@guanshanliu/)
- Organizer of [CocoaHeads Shanghai Meetup](http://www.meetup.com/CocoaHeads-Shanghai/)

![right 30%](Resources for Slides/qrcode.jpg)

---

[http://www.meetup.com/CocoaHeads-Shanghai/](http://www.meetup.com/CocoaHeads-Shanghai/)

---

# Schedule

1. 现实中 Reality
2. Demo
3. 传统式 Traditional / 响应式 Reactive
4. 近未来 The Future

---

# 现实中 
### Reality

---

# Apple
 
> Swift 3.0 relies entirely on platform concurrency primitives (libdispatch, Foundation, pthreads, etc.) for concurrency. Language support for concurrency is an often-requested and potentially high-value feature, but is too large to be in scope for Swift 3.0.
 
[Swift Thread Safety](https://github.com/apple/swift/blob/master/docs/proposals/Concurrency.rst)

---

# Grand Central Dispatch
#### GCD for short, A low-level C API

---

### *有人在想* Someone may think
# [fit] Asynchronous Programming with GCD is *easy*

---

# 很简单

```swift
dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
    })
}
```

---

# The Callback Hell *地狱*

```swift
dispatch_async(utilityQueue) {
    // Download image
    dispatch_async(mainQueue, {
        // Update UI
        dispatch_async(utilityQueue) {
            // Cache image
        }
    })
}
```

---

# The Callback Hell *地狱*
 
- Difficult to read
- Difficult to maintain
- Synchronization is painful

---

# [fit] What is hard in asynchronous programming?

---

# 同步 **难**
### Synchronization

---

# 同步 难

```swift
// Bad solution
dispatch_async(firstQueue) {
    dispatch_sync(secondQueue) {
        // Code requiring both queues, may risk dead-lock
    }
}
```

#### Example from [Justin Spahr-Summers](https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a)

---

# 同步 难

```swift
// Good solution
let concurrentQueue = dispatch_queue_create("concurrent", 
									DISPATCH_QUEUE_CONCURRENT)
dispatch_set_target_queue(firstQueue, concurrentQueue)
dispatch_set_target_queue(secondQueue, concurrentQueue)
dispatch_barrier_async(concurrentQueue) {
    // Code requiring both queues
}
```

#### Example from [Justin Spahr-Summers](https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a)

---

## `NSOperation`
##  `NSOperationQueue`
#### An Objective-C API on top of Grand Central Dispatch

---

# `NSOperation` & `NSOperationQueue`
 
- 依赖 Dependencies
- 状态监控 Observe the state using KVO
- 控制 More Controls: `maxConcurrentOperationCount`

---

# [fit] 错误处理 **难**
### Errors handling in 
### asynchronous scenarios

---

# 错误处理 难
 
1. Apple uses completion handlers to handle errors in asynchronous scenarios.
2. Apple's use of completion handlers is they are **always** called.
3. Completion handlers are called either with a result or an error.

---

# 错误处理 难

```swift
enum Result<T> {
	case Success(T)
	case Failure(ErrorType)
}
```

---

# 错误处理 难

1. No guarantee that an asynchronous function always calls a callback
2. No guarantee that an asynchronous function only calls a callback once
3. Do not know on which queue that a callback will be called

---
 
# [fit] 状态管理 **难**
### State Management

---

> The less state we have to manage, and the more declarative code we can write, the better.

- Brent Simmons

---

# 第三方
### 3rd Party Frameworks

---
 
# [BrightFuture](https://github.com/Thomvis/BrightFutures)
### Futures / Promises

---

# Reactive

1. [RxSwift](https://github.com/ReactiveX/RxSwift)
1. [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
1. [Bond](https://github.com/SwiftBond/Bond)
1. [VinceRP](https://github.com/bvic23/VinceRP)
1. [Interstellar](https://github.com/JensRavens/Interstellar)

---

# 异步编程难

- 同步难
- 错误处理难
- 状态管理难

---

# Demo

---

# Demo
 
- 搜索词发生，如果文字长度4个以上，发起新的请求，上一个请求被取消
- 0.3秒内搜索词多次变化，只有最后一次会发起请求
- 请求返回，界面需要更新
- 有一个刷新button，点击会立即发起请求

---

# Demo

---

# 近未来
### The Future

---

# Asyn - Await
 
```swift
func getAvatar() -> async UIImage
do {
   let image = await getAvatar()
   // Do something with the image
} catch {
   // Handle error
}
// Or
imageView.image <~ getAvatar()
```
 
---

# 谢谢
### Thank You
 
 ---
 
# 欢迎提问
### Questions?
