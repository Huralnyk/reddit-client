//
//  FeedViewController.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit

protocol FeedViewOutput {
    func viewIsReady()
    func didRequestRefreshing()
    func didRequestLoadMoreItems()
    func didSelectItem(at indexPath: IndexPath)
}

protocol FeedViewInput: AnyObject {
    func render(_ viewModel: FeedViewModel)
}

enum FeedViewModel {
    case loading
    case loaded(items: [RedditEntryViewModel])
}

class FeedViewController: UITableViewController, FeedViewInput {
    
    enum C {
        /// number of rows until the bottom of the list, when it's time to prefetch next page
        static let loadMoreTreshold = 5
    }
    
    private lazy var output: FeedViewOutput = FeedPresenter(
        provider: FeedProviderImpl(),
        view: self,
        router: FeedRouter(viewController: self)
    )
    
    private var items: [RedditEntryViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        output.viewIsReady()
    }
    
    // MARK: - View Input
    
    func render(_ viewModel: FeedViewModel) {
        switch viewModel {
        case .loading:
            refreshControl?.beginRefreshing()
        case .loaded(let items):
            refreshControl?.endRefreshing()
            self.items = items
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func onRefreshControlValueChange() {
        output.didRequestRefreshing()
    }
    
    // MARK: - Helpers
    
    private func initialSetup() {
        title = "Popular Posts"
        tableView.register(RedditEntryTableViewCell.self)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(onRefreshControlValueChange), for: .valueChanged)
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RedditEntryTableViewCell.self, for: indexPath)
        cell.render(items[indexPath.row])
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.didSelectItem(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (items.count - indexPath.row) < C.loadMoreTreshold {
            output.didRequestLoadMoreItems()
        }
    }
}
