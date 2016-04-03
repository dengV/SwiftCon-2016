//: [Previous](@previous)

import UIKit
import XCPlayground

func getAvatar(onCompletion: UIImage? -> Void) {
    let queue = NSOperationQueue()
    queue.qualityOfService = .Background
    let url = NSURL(string: "https://api.github.com/users/guanshanliu")!
    let session = NSURLSession(configuration: .defaultSessionConfiguration(),
                               delegate: nil, delegateQueue: NSOperationQueue())
    let task = session.dataTaskWithURL(url) { (maybeData, response, error) in
        guard error == nil else { return }
        guard let data = maybeData else { return }
        
        let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])).flatMap{ $0 as? [String: AnyObject] }
        guard let dictionary = json  else { return }
        
        let imageURL = dictionary["avatar_url"] as! String
        let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!)!
        let image = UIImage(data: imageData)
        
        dispatch_async(dispatch_get_main_queue()) {
            onCompletion(image)
        }
    }
    task.resume()
}

//getAvatar { maybeImage in
//    maybeImage
//    XCPlaygroundPage.currentPage.finishExecution()
//}
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: # Futures (a.k.a Promises)

//: # Result
//: ### [Result](https://github.com/antitypical/Result) by Rob Rix
//: ```
//: enum Result<Value, Error: ErrorType> {
//:     case Success(Value)
//:     case Failure(Error)
//: }
//: ```

//func getAvatar() -> Future<UIImage, IgnoreError> {
//    return Future { completion in
//        let queue = NSOperationQueue()
//        queue.qualityOfService = .Background
//        let url = NSURL(string: "https://api.github.com/users/guanshanliu")!
//        let session = NSURLSession(configuration: .defaultSessionConfiguration(),
//            delegate: nil, delegateQueue: NSOperationQueue())
//        let task = session.dataTaskWithURL(url) { (maybeData, response, error) in
//            guard error == nil else { return }
//            guard let data = maybeData else { return }
//
//            let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])).flatMap{ $0 as? [String: AnyObject] }
//            guard let dictionary = json  else { return }
//
//            let imageURL = dictionary["avatar_url"] as! String
//            let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!)!
//
//            if let image = UIImage(data: imageData) {
//                completion(.Success(image))
//            }
//        }
//        task.resume()
//    }
//}

//getAvatar().onSuccess { image in
//    image
//    print(image)
//}.onFailure { error in
//    error
//}

func getAvatar() -> Future<String, IgnoreError> {
    return Future { completion in
        let queue = NSOperationQueue()
        queue.qualityOfService = .Background
        let url = NSURL(string: "https://api.github.com/users/guanshanliu")!
        let session = NSURLSession(configuration: .defaultSessionConfiguration(),
            delegate: nil, delegateQueue: NSOperationQueue())
        let task = session.dataTaskWithURL(url) { (maybeData, response, error) in
            guard error == nil else { return }
            guard let data = maybeData else { return }
            
            let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])).flatMap{ $0 as? [String: AnyObject] }
            guard let dictionary = json  else { return }
            
            let imageURL = dictionary["avatar_url"] as! String
            completion(.Success(imageURL))
        }
        task.resume()
    }
}

//let fetchImage: Future<UIImage, IgnoreError> = getAvatar().map { url in
//    let data = NSData(contentsOfURL: NSURL(string: url)!)!
//    return UIImage(data: data)!
//}
//fetchImage.onSuccess { image in
//    image
//    XCPlaygroundPage.currentPage.finishExecution()
//}
//
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

/// # BrightFuture
/// ### [Open-sourced by Thomas Visser](https://github.com/Thomvis/BrightFutures)

//: ```
//: func getAvatar() -> async String
//: ```

//: # Asyn - Await

//: ```
//: func getAvatar() -> async String
//:
//: do {
//:     let image = await getAvatar()
//:     // Do something with the image
//: } catch {
//:     // Handle error
//: }
//: ```

//: [Next](@next)
