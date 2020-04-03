//
//  Mappers.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation
import CoreData

enum Mappers {
    static func toManagedObject(_ entry: RedditEntry, in context: NSManagedObjectContext) -> RedditEntryMO {
        let managedObject = RedditEntryMO(context: context)
        managedObject.name = entry.name
        managedObject.title = entry.title
        managedObject.author = entry.author
        managedObject.numberOfComments = entry.numberOfComments
        managedObject.thumbnail = entry.thumbnail
        managedObject.previewImage = entry.previewImage
        managedObject.score = entry.score
        managedObject.created = entry.created
        return managedObject
    }
    
    static func toPlainObject(_ managedObject: RedditEntryMO) -> RedditEntry {
        return RedditEntry(
            name: managedObject.name,
            title: managedObject.title,
            author: managedObject.author,
            numberOfComments: Int(managedObject.numberOfComments),
            thumbnail: managedObject.thumbnail,
            previewImage: managedObject.previewImage,
            score: managedObject.score,
            created: managedObject.created
        )
    }
}
