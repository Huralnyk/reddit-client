//
//  RedditPageMO+CoreDataProperties.swift
//  
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(RedditPageMO)
public class RedditPageMO: NSManagedObject {

}

extension RedditPageMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RedditPageMO> {
        return NSFetchRequest<RedditPageMO>(entityName: "RedditPageMO")
    }
    
    @NSManaged public var entries: NSOrderedSet
    @NSManaged public var nextToken: String?
}
