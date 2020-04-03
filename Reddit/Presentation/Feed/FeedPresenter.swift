//
//  FeedPresenter.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 03.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

final class FeedPresenter: FeedViewOutput {
    
    private weak var view: FeedViewInput?
    private let provider: FeedProvider
    private let router: FeedRouter
    
    private var viewModels: [RedditEntryViewModel] = [] {
        didSet {
            view?.render(.loaded(items: viewModels))
        }
    }
    
    init(provider: FeedProvider, view: FeedViewInput?, router: FeedRouter) {
        self.provider = provider
        self.view = view
        self.router = router
    }
    
    // MARK: - View Output
    
    func viewIsReady() {
        provider.itemsUpdateHandler = { [weak self] items in
            let viewModels = items.map(RedditEntryViewModel.init)
            DispatchQueue.main.async {
                self?.viewModels = viewModels
            }
        }
        
        view?.render(.loading)
        provider.fetchTopItems()
    }
    
    func didRequestRefreshing() {
        view?.render(.loading)
        provider.fetchTopItems()
    }
    
    func didRequestLoadMoreItems() {
        provider.fetchNextPage()
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        if let url = viewModels[indexPath.row].fullImageURL {
            router.route(to: .webView(url: url))
        }
    }
}
