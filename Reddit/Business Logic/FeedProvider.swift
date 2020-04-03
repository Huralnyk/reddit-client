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

protocol FeedProvider: AnyObject {
    var itemsUpdateHandler: Callback<[RedditEntry]> { get set }
    func fetchTopItems()
    func fetchNextPage()
}

final class FeedProviderImpl: FeedProvider {
    
    var itemsUpdateHandler: Callback<[RedditEntry]> = { _ in }
    
    private let networkService: NetworkService
    private let coreDataStack: NSPersistentContainer
    
    private var pages: [RedditPage] = [] {
        didSet {
            itemsUpdateHandler(pages.flatMap { $0.children })
        }
    }
    
    init(
        networkService: NetworkService = Dependencies.networkService,
        coreDataStack: NSPersistentContainer = Dependencies.persistentContainer
    ) {
        self.networkService = networkService
        self.coreDataStack = coreDataStack
    }
    
    func fetchTopItems() {
        fetchCached(then: { [weak self] in
            self?.updateTopPage()
        })
    }
    
    func fetchNextPage() {
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
    
    private func fetchCached(then handler: @escaping VoidCallback) {
        coreDataStack.performBackgroundTask { [weak self] context in
            do {
                let request: NSFetchRequest<RedditPageMO> = RedditPageMO.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \RedditPageMO.date, ascending: true)]
                let cached = try context.fetch(request).map(Mappers.toPlaingObject)
                self?.pages = cached
                handler()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateTopPage() {
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
    
    private func invalidateCache() {
        let context = coreDataStack.newBackgroundContext()
        do {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: RedditPageMO.fetchRequest())
            try context.execute(batchDeleteRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func store(page: RedditPage) {
        let context = coreDataStack.newBackgroundContext()
        do {
            let fetchRequest: NSFetchRequest<RedditPageMO> = RedditPageMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "nextToken == %@", page.after ?? "")
            guard try context.count(for: fetchRequest) == 0 else { return }
            print("storing page with token \(page.after ?? "")")
            _ = Mappers.toManagedObject(page, in: context)
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
