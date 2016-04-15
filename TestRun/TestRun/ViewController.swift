//
//  ViewController.swift
//  TestRun
//
//  Created by Guanshan Liu on 4/15/16.
//  Copyright © 2016 Guanshan Liu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Fetcher {
    static func fetchItems(query: String) -> Observable<[String]> {
        return Observable.create { observer in
            let apiKey = "f6ed5058e2ec06535e1f68aab2720ff7"
            let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let urlContent = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
            let url = NSURL(string: urlContent)!
            let request = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
                guard error == nil,
                    let data = data,
                    let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                    let items = parseForMovieTitles(json)
                    else {
                        observer.onError(ParseError.InvalidFormat)
                        return
                }
                sleep(1)
                observer.onNext(items)
                observer.onCompleted()
            }
            
            request.resume()
            
            return AnonymousDisposable {
                request.cancel()
            }
        }
    }
}

enum ParseError: ErrorType {
    case InvalidFormat
}

func parseForMovieTitles(json: AnyObject) -> [String]? {
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

class ViewController: UITableViewController {
    var results = [String]()
    
    let disposeBag = DisposeBag()
    
    let searchBar = UISearchBar()
    let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        let search = searchBar.rx_text
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { text in
                return text.characters.count > 3
        }
        
        let refresh = refreshButton.rx_tap.withLatestFrom(search)
        
        Observable.of(search, refresh).merge().flatMapLatest {
            return Fetcher.fetchItems($0)
            }.observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] titles in
                self?.results = titles
                self?.tableView.reloadData()
            }.addDisposableTo(disposeBag)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = results[indexPath.row]
        return cell
    }
    
    func setupView() {
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = refreshButton
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

