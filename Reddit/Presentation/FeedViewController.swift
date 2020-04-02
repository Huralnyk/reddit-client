//
//  FeedViewController.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UITableViewCell {
    static var nibName: String {
        return String(describing: self)
    }
}

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellType: T.Type) where T: NibLoadable, T: Reusable {
        register(UINib(nibName: T.nibName, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeue<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("\(T.reuseIdentifier) is not registered as reusable cell")
        }
        return cell
    }
}

class FeedViewController: UITableViewController {
    
    private let networkService: NetworkService = NetworkServiceImpl()
    
    private var viewModels: [RedditEntryViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RedditEntryTableViewCell.self)
        
        // TODO: - Test Code
        networkService.get(path: "top.json", parameters: ["limit": 25]) { (result) in
            if case let .success(data) = result {
                let page = try? JSONDecoder().decode(RedditPage.self, from: data)
                let viewModels = (page?.children ?? []).map(RedditEntryViewModel.init)
                DispatchQueue.main.async {
                    self.viewModels = viewModels
                }
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RedditEntryTableViewCell.self, for: indexPath)
        cell.render(viewModels[indexPath.row])
        return cell
    }
    
}
