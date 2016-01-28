//
//  Box.swift
//  Virtual Tourist
//
//  Created by Nick Short on 17/01/2016.
//  Copyright © 2016 Nick Short. All rights reserved.
//

import Foundation
import CoreData

class Box:NSManagedObject{
    
    struct Keys{
        static let minLong = "minLong"
        static let minLat = "minLat"
        static let maxLong = "maxLong"
        static let maxLat = "maxLat"
        static let pageNumber = "pageNumber"        
    }
    
    @NSManaged var minLong:NSNumber
    @NSManaged var minLat:NSNumber
    @NSManaged var maxLong:NSNumber
    @NSManaged var maxLat:NSNumber
    @NSManaged var pageNumber: NSNumber
    @NSManaged var pin:Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Box", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        minLong = dictionary[Box.Keys.minLong] as! NSNumber
        minLat = dictionary[Box.Keys.minLat] as! NSNumber
        maxLong = dictionary[Box.Keys.maxLong] as! NSNumber
        maxLat = dictionary[Box.Keys.maxLat] as! NSNumber
        pageNumber = dictionary[Keys.pageNumber] as! NSNumber
    }
    
    
}
