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
    
    private var entries: [RedditEntry] = [] {
        didSet {
            itemsUpdateHandler(entries)
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
        guard let nextToken = entries.last?.name else { return }
        let params: [String: Any] = ["limit": 10, "after": nextToken]
        networkService.getDecoded(RedditPage.self, path: "top.json", parameters: params) { [weak self] result in
            switch result {
            case .success(let page):
                self?.entries.append(contentsOf: page.children)
                self?.store(page: page)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchCached(then handler: @escaping VoidCallback) {
        coreDataStack.performBackgroundTask { [weak self] context in
            do {
                let request: NSFetchRequest<RedditEntryMO> = RedditEntryMO.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \RedditEntryMO.score, ascending: false)]
                self?.entries = try context.fetch(request).map(Mappers.toPlainObject)
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
    
    private func store(page: RedditPage) {
        let context = coreDataStack.newBackgroundContext()
        do {
            _ = page.children.map { Mappers.toManagedObject($0, in: context) }
            let count = try context.count(for: RedditEntryMO.fetchRequest())
            print("total entries: \(count)")
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func merge(top: RedditPage) {
        if entries.first?.name != top.children.first?.name {
            entries = top.children
            store(page: top)
        }
    }
    
    private func append(page: RedditPage) {
        if let first = page.children.first, !entries.contains(where: { $0.name == first.name }) {
            entries.append(contentsOf: page.children)
        }
    }
}
