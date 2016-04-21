import Foundation

public class Fetcher {
    let task: NSURLSessionDataTask
    
    public init(query: String, callback: (result: [String]?, error: ErrorType?) -> Void) {
        let apiKey = "f6ed5058e2ec06535e1f68aab2720ff7"
        let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
        let urlContent = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        let url = NSURL(string: urlContent)!
        
        task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
            guard error == nil,
                let data = data,
                let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                let items = parseForMovieTitles(json)
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(result: nil, error: ParseError.InvalidFormat)
                    }
                    return
            }
            dispatch_async(dispatch_get_main_queue()) {
                callback(result: items, error: nil)
            }
        }
        
        task.resume()
    }
    
    public func cancel() {
        task.cancel()
    }
}