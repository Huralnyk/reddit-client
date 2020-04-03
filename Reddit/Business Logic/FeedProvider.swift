//
//  FeedProvider.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 03.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation
import CoreData

typealias VoidCallback = () -> Void
typealias Callback<T> = (T) -> Void

final class FeedProvider {
    
    private let networkService: NetworkService
    private let coreDataStack: NSPersistentContainer
    
    var onItemsUpdate: Callback<[RedditEntry]> = { _ in }
    
    private var pages: [RedditPage] = [] {
        didSet {
            onItemsUpdate(pages.flatMap { $0.children })
        }
    }
    
    init(
        networkService: NetworkService = Dependencies.networkService,
        coreDataStack: NSPersistentContainer = Dependencies.persistentContainer
    ) {
        self.networkService = networkService
        self.coreDataStack = coreDataStack
    }
    
    func fetchItems() {
        fetchCached(then: updateTop)
    }
    
    private func fetchCached(then handler: @escaping VoidCallback) {
        coreDataStack.performBackgroundTask { [weak self] context in
            do {
                let request: NSFetchRequest<RedditPageMO> = RedditPageMO.fetchRequest()
                let cached = try context.fetch(request).map(Mappers.toPlaingObject)
                self?.pages = cached
                handler()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateTop() {
        let params: [String: Any] = ["limit": 10]
        networkService.getDecoded(RedditPage.self, path: "top.json", parameters: params) { [weak self] result in
            switch result {
            case .success(let page):
                self?.merge(top: page)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchNext() {
        guard let nextToken = pages.last?.after else { return }
        let params: [String: Any] = ["limit": 10, "after": nextToken]
        networkService.getDecoded(RedditPage.self, path: "top.json", parameters: params) { [weak self] result in
            switch result {
            case .success(let page):
                self?.pages.append(page)
                self?.store(page: page)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func store(page: RedditPage) {
        let context = coreDataStack.newBackgroundContext()
        _ = Mappers.toManagedObject(page, in: context)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func merge(top: RedditPage) {
        guard pages.first?.after != top.after else { return }
        pages.insert(top, at: 0)
        store(page: top)
    }
}
