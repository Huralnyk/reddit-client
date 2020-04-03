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
    static func toManagedObject(_ page: RedditPage, in context: NSManagedObjectContext) -> RedditPageMO {
        let managedObject = RedditPageMO(context: context)
        let entries = page.children.map { toManagedObject($0, in: context) }
        managedObject.entries = NSOrderedSet(array: entries)
        managedObject.nextToken = page.after
        managedObject.date = .now
        return managedObject
    }
    
    static func toPlaingObject(_ page: RedditPageMO) -> RedditPage {
        let children = page.entries.compactMap { $0 as? RedditEntryMO }.map(toPlainObject)
        return RedditPage(children: children, after: page.nextToken)
    }
    
    static func toManagedObject(_ entry: RedditEntry, in context: NSManagedObjectContext) -> RedditEntryMO {
        let managedObject = RedditEntryMO(context: context)
        managedObject.name = entry.name
        managedObject.title = entry.title
        managedObject.author = entry.author
        managedObject.numberOfComments = Int32(entry.numberOfComments)
        managedObject.thumbnail = entry.thumbnail
        managedObject.previewImage = entry.previewImage
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
            created: managedObject.created
        )
    }
}
