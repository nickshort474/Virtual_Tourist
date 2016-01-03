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

class PhotoAlbumViewController:UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var selectedCells = [NSIndexPath]()
    
    var insertIndexPaths:[NSIndexPath]!
    var deleteIndexPaths:[NSIndexPath]!
    var changeIndexPaths:[NSIndexPath]!
    
    override func viewDidLoad() {
        
        collectionView.delegate = self
        print("collection view")
        
        
        var error:NSError?
        
        do{
           try fetchedResultsController.performFetch()
        }catch let error1 as NSError{
            error = error1
        }
        
        if let error = error{
            print("error performing fetch: \(error)")
        }
        
    }
    
    
    // get shared context
    lazy var sharedContext:NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // create fetchedResultsController
    lazy var fetchedResultsController:NSFetchedResultsController = {
       
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    
    // collection view methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections!.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        print("number of cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! CollectionViewCell
        
       
        let localImagePath = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let localString = localImagePath.imagePath
        
        
        
        let url = NSURL(string: localString)
        
        let imageData:NSData = NSData(contentsOfURL: url!)!
        
        cell.cellImageView.image = UIImage(data: imageData)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if let index = selectedCells.indexOf(indexPath){
            selectedCells.removeAtIndex(index)
        }else{
            selectedCells.append(indexPath)
        }
    }
    
    
    // fetchedResults methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // TODO: implement method
        insertIndexPaths = [NSIndexPath]()
        deleteIndexPaths = [NSIndexPath]()
        changeIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            print("insert an item")
            insertIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("deleting an item")
            deleteIndexPaths.append(indexPath!)
            break
        case .Update:
            print("changing an item")
            changeIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertIndexPaths{
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deleteIndexPaths{
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.changeIndexPaths{
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        },completion:nil)
    }
    // TODO: Configure cell
    
}