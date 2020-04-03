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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RedditEntryMO> {
        return NSFetchRequest<RedditEntryMO>(entityName: "RedditEntryMO")
    }

    @NSManaged public var name: String
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var numberOfComments: Int32
    @NSManaged public var thumbnail: URL
    @NSManaged public var previewImage: URL?
    @NSManaged public var created: Date
    @NSManaged public var page: RedditPageMO

}
