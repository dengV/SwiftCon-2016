//: [Previous](@previous)

import UIKit
import XCPlayground

let queue = NSOperationQueue()
queue.qualityOfService = .Background

let url = NSURL(string: "https://api.github.com/zen")!
let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue())
let task = session.dataTaskWithURL(url) { (data, response, error) in
    
    guard error == nil else {
        XCPlaygroundPage.currentPage.finishExecution()
    }
    
    guard let data = data,
        text = String(data: data, encoding: NSUTF8StringEncoding)
        else {
            XCPlaygroundPage.currentPage.finishExecution()
    }
    
    dispatch_async(dispatch_get_main_queue()) {
        print(text)
        XCPlaygroundPage.currentPage.finishExecution()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
task.resume()


//: [Next](@next)
