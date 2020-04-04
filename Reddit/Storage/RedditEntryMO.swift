//
//  RedditEntryMO+CoreDataProperties.swift
//  
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(RedditEntryMO)
public class RedditEntryMO: NSManagedObject {
    
}

extension RedditEntryMO {
    @NSManaged public var name: String
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var numberOfComments: Int
    @NSManaged public var thumbnail: URL
    @NSManaged public var previewImage: URL?
    @NSManaged public var score: Int
    @NSManaged public var created: Date
}

extension NSFetchRequest where ResultType == RedditEntryMO {
    static func all() -> NSFetchRequest<RedditEntryMO> {
        let request = NSFetchRequest<RedditEntryMO>(entityName: "RedditEntryMO")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RedditEntryMO.score, ascending: false)]
        return request
    }
}
