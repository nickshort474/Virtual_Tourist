//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Nick Short on 22/11/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewController:UIViewController{
    
    
    override func viewDidLoad() {
        
    }
    
    
    
    lazy var sharedContext:NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
}