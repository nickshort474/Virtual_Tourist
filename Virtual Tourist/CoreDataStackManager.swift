//
//  CoreDataStackManager.swift
//  Virtual Tourist
//


import Foundation
import CoreData



private let SQLITE_FILE_NAME = "PinnedPlaces.sqlite"

class CoreDataStackManager {
    
    
    
   // set class as singleton
    
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
    
        return Static.instance
    }
    
    
    
    // set application docuemnts directory
    
    lazy var applicationDocumentsDirectory: NSURL = {
        
        
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    
    
    // set object model reference
    
    lazy var managedObjectModel: NSManagedObjectModel = {
       
        let modelURL = NSBundle.mainBundle().URLForResource("Virtual_Tourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    
    // set persistent store coordinator
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
                let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
                var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            
            // Report errors
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
           
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
        }
        
        return coordinator
    }()
    
    
    
    // set context
    
    lazy var managedObjectContext: NSManagedObjectContext = {
      
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    //
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
    }
}



