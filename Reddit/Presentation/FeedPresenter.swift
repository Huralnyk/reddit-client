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
    
    init(provider: FeedProvider, view: FeedViewInput?) {
        self.provider = provider
        self.view = view
    }
    
    func viewIsReady() {
        provider.onItemsUpdate = { [weak self] items in
            let viewModels = items.map(RedditEntryViewModel.init)
            DispatchQueue.main.async {
                self?.view?.render(.loaded(items: viewModels))
            }
        }
        
        view?.render(.loading)
        provider.fetchItems()
    }
    
    func didRequestRefreshing() {
        view?.render(.loading)
        provider.fetchItems()
    }
    
    func didRequestLoadMoreItems() {
        provider.fetchNext()
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        
    }
    
    func didRequestPrefetching(at indexPaths: [IndexPath]) {
        
    }
    
    func didCancelPrefetching(at indexPaths: [IndexPath]) {
        
    }
}
