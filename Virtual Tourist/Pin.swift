//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Nick Short on 20/12/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import Foundation
import CoreData

class Pin:NSManagedObject{
    
    struct Keys{
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let firstTransition = "firstTransition"
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var firstTransition:String
    @NSManaged var photos:[Photo]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.latitude] as! NSNumber
        longitude = dictionary[Keys.longitude] as! NSNumber
        firstTransition = dictionary[Keys.firstTransition] as! String
    }
    
    
    
    
    
}