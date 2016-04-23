//: [Previous](@previous) | [Introduction](Introduction)

import XCPlayground
import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {
    var results = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    let searchBar = UISearchBar()
    
    // Live code begin
    lazy var throttle: Throttle<String> = {
        let throttle = Throttle(timeout: 0.3, callback: self.runFetch)
        throttle.condition = { query in
            query.characters.count > 3
        }
        return throttle
    }()
    
    var fetcher: Fetcher? {
        willSet {
            fetcher?.cancel()
        }
    }
    
    var currentText = "" {
        didSet {
            throttle.update(currentText, ignore: ==)
        }
    }
    
    func runFetch(query: String) {
        fetcher = Fetcher(query: query) { [weak self] result, error in
            guard error == nil,
                let titles = result
                else {
                    return
            }
            self?.results = titles
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        currentText = searchText
    }
    
    func refreshDidTap() {
        runFetch(currentText)
    }
    
    // Live code end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: #selector(ViewController.refreshDidTap))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        searchBar.delegate = self;
    }
}

let viewController = ViewController()
let navigationController = UINavigationController(rootViewController: viewController)

XCPlaygroundPage.currentPage.liveView = navigationController

//: [Next](@next) | [Introduction](Introduction)
