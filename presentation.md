## Asynchronous Programming in Swift
# 异步
#### 刘冠杉  (@guanshanliu)

---

# About Me

- Guanshan Liu 刘冠杉
- Senior iOS Developer at Alibaba Inc.
- Twitter:  [@guanshanliu][1] 
- Blog: [https://guanshanliu.typed.com][2]
- GitHub: [GaunshanLiu][3]

---

# 异步
### Asynchronous

---

# Grand Central Dispatch
### A low-level C API

---

# I know Grand Central Dispatch. And It is easy.

```swift
// Do something
dispatch_async(queue) {
    // Do something else
}
```

---

# It is still easy.

```swift
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
    Int64(2.0 * Double(NSEC_PER_SEC))), 
    dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
    // Do something...
    dispatch_async(dispatch_get_main_queue(), { 
        // DO something else...
    })
}
```

---

# Be careful when synchronizing with multiple GCD queues

```swift
// Bad. You risk a deadlock
dispatch_async(firstQueue) {
    dispatch_sync(secondQueue) {
        // code requiring both queues
    }
}
```

---

# Be careful when synchronizing with multiple GCD queues

```swift
// Synchronizing with multiple GCD queues
let concurrentQueue 
    = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
dispatch_set_target_queue(firstQueue, concurrentQueue)
dispatch_set_target_queue(secondQueue, concurrentQueue)
dispatch_barrier_async(concurrentQueue) {
    // code requiring both queues
}
```

#### by [Justin Spahr-Summers][4]

---

## Don't let other's API stop us becoming `Swift-y`

---

# Swift-y GCD

```swift
enum Queue {
    case main
    case userInteractive
    case userInitiated
    case defaults
    case utility
    case background
}
```

---

# Swift-y GCD

```swift
enum Queue {
    var dispatchQueue: dispatch_queue_t {
        switch self {
        case .main: return dispatch_get_main_queue()
        case .userInteractive:
            return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .userInitiated:
            return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .defaults:
            return dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
        case .utility:
            return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .background:
            return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        }
    }
}
```

---

# Swift-y GCD

```swift
func async(queue: Queue = .main, _ block: dispatch_block_t) {
    dispatch_async(queue.dispatchQueue, block)
}
```
```swift
func delay(seconds: Double, 
    queue: Queue = .main, 
    _ block: dispatch_block_t) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
        Int64(seconds * Double(NSEC_PER_SEC))), 
        queue.dispatchQueue, 
        block)
}
```

---

# Plain GCD

```swift
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 
    Int64(2.0 * Double(NSEC_PER_SEC))), 
    dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
    // Do something...
    dispatch_async(dispatch_get_main_queue(), { 
        // DO something else...
    })
}
```

---

# Swift-y GCD

```swift
delay(2.0, queue: .utility) {
    // Do something...
    async() {
        // DO something else...
    }
}
```

---

# GCD with Network

```swift
let queue = NSOperationQueue()
queue.qualityOfService = .Background
let url = NSURL(string: "https://api.github.com/zen")!
let session = NSURLSession(configuration: .defaultSessionConfiguration(), 
					       delegate: nil, delegateQueue: NSOperationQueue())
let task = session.dataTaskWithURL(url) { (data, response, error) in
    guard error == nil else { return }
    guard let data = data,
        text = String(data: data, encoding: NSUTF8StringEncoding)
        else { return }
    dispatch_async(dispatch_get_main_queue()) {
        print(text) // print: Favor focus over features
    }
}
task.resume()
```

---

## `NSOperation`
## `NSOperationQueue`
#### An Objective-C API on top of Grand Central Dispatch

---

# 依赖 Dependencies

```swift
let taskA = NSBlockOperation {
    print("A", separator: "", terminator: "")
}
let taskB = NSBlockOperation {
    print("B", separator: "", terminator: "")
}
let taskC = NSBlockOperation {
    print("C", separator: "", terminator: "")
}
taskC.addDependency(taskA)
taskC.addDependency(taskB)
let taskD = NSBlockOperation {
    print("D", separator: "")
}
taskD.addDependency(taskC)
```

---

# 依赖 Dependencies

```swift
let queue = NSOperationQueue()
queue.addOperation(taskD)
queue.addOperation(taskC)
queue.addOperation(taskB)
queue.addOperation(taskA)
queue.waitUntilAllOperationsAreFinished()
// Print: BACD
```

---

# 监控 Monitor the state using KVO

```swift
public class NSOperation : NSObject {
    public var executing: Bool { get }
    public var finished: Bool { get }
    public var asynchronous: Bool { get }
    public var ready: Bool { get }
}
public class NSOperationQueue : NSObject {
    public var suspended: Bool
}
```

---

# 控制 More Controls

```swift
public class NSOperation : NSObject {
    public func cancel()
}
public class NSOperationQueue : NSObject {
    public var maxConcurrentOperationCount: Int
    public var suspended: Bool
    public func cancelAllOperations()
    public func waitUntilAllOperationsAreFinished()
}
```

---

# A Modern Network Operation
#### [by Marcus Zarra][5]

---

# A Modern Network Operation

```swift
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    let incomingData = NSMutableData()
    var sessionTask: NSURLSessionTask?
    let localConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var localURLSession = NSURLSession(configuration: self.localConfig, 
                                            delegate: self, 
                                            delegateQueue: nil)
    var junk: Bool = false
    override var finished: Bool {
        get {
            return junk
        }
        set (newAnswer) {
            willChangeValueForKey("isFinished")
            junk = newAnswer
            didChangeValueForKey("isFinished")
        }
    }
}
```

---

# A Modern Network Operation

```swift
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    override func start() {
        if cancelled {
            finished = true
            return
        }
        let url = NSURL(string: "https://api.github.com/zen")!
        let request = NSMutableURLRequest(URL: url)
        sessionTask = localURLSession.dataTaskWithRequest(request)
        sessionTask!.resume()
    }
}
```

---

# A Modern Network Operation

```swift
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession,
                    dataTask: NSURLSessionDataTask,
                    didReceiveResponse response: NSURLResponse,
                    completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        //Check the response code and react appropriately
        completionHandler(.Allow)
    }
}
```

---

# A Modern Network Operation

```swift
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession,
                    dataTask: NSURLSessionDataTask,
                    didReceiveData data: NSData) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        incomingData.appendData(data)
    }
}
```

---

# A Modern Network Operation

```swift
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        guard error == nil else {
            finished = true
            return
        }
        // Process data
        if let text = String(data: incomingData, encoding: NSUTF8StringEncoding) {
            print(text)
        }
        finished = true
    }
}
```

---

# References

- [A Modern Network Operation by Marcus Zarra][5]

---

# 谢谢
### Thank you

---

# 欢迎提问
### Questions?

[1]: https://twitter.com/guanshanliu
[2]: http://guanshanliu.typed.com
[3]: https://github.com/guanshanliu
[4]: https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a
[5]: https://gist.github.com/jspahrsummers/dbd861d425d783bd2e5a