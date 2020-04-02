//
//  FeedViewController.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController {
    
    private var viewModels: [RedditEntryViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RedditEntryTableViewCell.self)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func didPullToRefresh() {
        print(#function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RedditEntryTableViewCell.self, for: indexPath)
        cell.render(viewModels[indexPath.row])
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(#function)
    }
    
}
