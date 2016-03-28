//: [Previous](@previous)

import Foundation

// Learn from [A Modern Network Operation by Marcus Zarra](http://www.cimgf.com/2016/01/28/a-modern-network-operation/)
class NetworkOperation: NSOperation, NSURLSessionDataDelegate {
    
    let incomingData = NSMutableData()
    var sessionTask: NSURLSessionTask?
    let localConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var localURLSession: NSURLSession = NSURLSession(configuration: self.localConfig, delegate: self, delegateQueue: nil)
    
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
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        guard error == nil else {
            print("Failed to receive response: \(error)")
            finished = true
            return
        }
        processData()
        finished = true
    }
    
    func processData() {
        if let text = String(data: incomingData, encoding: NSUTF8StringEncoding) {
            print(text)
        }
    }
}

let operation = NetworkOperation()
let queue = NSOperationQueue()
queue.qualityOfService = .Background
queue.addOperations([operation], waitUntilFinished: true)

//: [Next](@next)
