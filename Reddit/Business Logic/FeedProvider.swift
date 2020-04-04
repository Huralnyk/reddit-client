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

final class FeedProviderImpl: NSObject, FeedProvider {
    
    enum C {
        static let path = "top.json"
        static let parameters: [String: Any] = ["limit": 10]
    }
    
    var itemsUpdateHandler: Callback<[RedditEntry]> = { _ in }
    
    private let networkService: NetworkService
    private let persistentContainer: NSPersistentContainer
    private let fetchedResultsController: NSFetchedResultsController<RedditEntryMO>
    private var isFetchingNextPage = false
    
    private var entries: [RedditEntry] = [] {
        didSet {
            itemsUpdateHandler(entries)
        }
    }
    
    init(
        networkService: NetworkService = Dependencies.networkService,
        persistentContainer: NSPersistentContainer = Dependencies.persistentContainer
    ) {
        self.networkService = networkService
        self.persistentContainer = persistentContainer
        self.fetchedResultsController = NSFetchedResultsController<RedditEntryMO>(
            fetchRequest: .all(),
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func fetchTopItems() {
        networkService.getDecoded(RedditPage.self, path: C.path, parameters: C.parameters) { [weak self] result in
            guard let self = self else { return }
            self.handle(result: result)
        }
        perfromThrowing(fetchedResultsController.performFetch)
        entries = fetchedResultsController.fetchedObjects?.map(Mappers.toPlainObject) ?? []
    }
    
    func fetchNextPage() {
        guard !isFetchingNextPage, let lastEntry = entries.last?.name else { return }
        
        isFetchingNextPage = true
        let parameters = C.parameters.adding(value: lastEntry, forKey: "after")
        networkService.getDecoded(RedditPage.self, path: C.path, parameters: parameters) { [weak self] result in
            guard let self = self else { return }
            self.isFetchingNextPage = false
            self.handle(result: result)
        }
    }
    
    // MARK: - Helpers
    
    private func handle(result: Result<RedditPage, Error>) {
        switch result {
        case .success(let page):
            sync(entries: page.children)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    private func sync(entries: [RedditEntry]) {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        _ = entries.map { Mappers.toManagedObject($0, in: context)}
        if context.hasChanges {
            perfromThrowing(context.save)
        }
    }
}

extension FeedProviderImpl: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        entries = fetchedResultsController.fetchedObjects?.map(Mappers.toPlainObject) ?? []
    }
}
