//
//  Dependencies.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 03.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation
import CoreData

enum Dependencies {
    
    static let networkService: NetworkService = NetworkServiceImpl()
    
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Reddit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}