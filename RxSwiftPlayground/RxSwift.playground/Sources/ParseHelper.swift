import Foundation

public enum ParseError: ErrorType {
    case InvalidFormat
}

public func parseForMovieTitles(json: AnyObject) -> [String]? {
    guard let dictionary = json as? [String: AnyObject],
        let results = dictionary["results"] as? [[String: AnyObject]]
        else {
            return nil
    }
    return results.flatMap { movie -> String? in
        if let title = movie["title"] as? String {
            return title
        }
        return nil
    }
}