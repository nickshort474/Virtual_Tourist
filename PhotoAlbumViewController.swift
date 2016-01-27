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
import MapKit

class PhotoAlbumViewController:UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate,MKMapViewDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var removePictures: UIButton!
    
    
    var currentPinAnnotation:PinAnnotation!
    var currentPin:Pin!
    
    var selectedCells = [NSIndexPath]()
    
    var insertIndexPaths:[NSIndexPath]!
    var deleteIndexPaths:[NSIndexPath]!
    var changeIndexPaths:[NSIndexPath]!
   
    
    
    override func viewDidLoad() {
        
        removePictures.hidden = true
        collectionView.delegate = self
        
        newCollection.enabled = false
        newCollection.alpha = 0.5
        
        currentPin = self.currentPinAnnotation.pin
        addPinToMap()
        
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
        fetchRequest.predicate = NSPredicate(format:"pin == %@", self.currentPin)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    
    // MAP CODE
    func addPinToMap(){
        let latitude = currentPin.latitude
        let longitude = currentPin.longitude
        
        let annotation = MKPointAnnotation()
        let pinCoords:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
        annotation.coordinate = pinCoords
        mapView.addAnnotation(annotation)
        
        self.centerMap(pinCoords)
    }
    
    
    func centerMap(coords:CLLocationCoordinate2D){
        
        let coordSpan = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        
        let coordinateRegion = MKCoordinateRegionMake(coords,coordSpan)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    
    
    
    // COLLECTION VIEW CODE
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController.sections!.count
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! CollectionViewCell
        
        
        cell.cellImageView.image = UIImage(named:"placeholder")
        
        if(fetchedResultsController.fetchedObjects?.count != 0){
           
            let imageReference = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            let pathToImage = imageReference.imagePath
            
            if let imageData = NSFileManager.defaultManager().contentsAtPath(pathToImage){
                cell.cellImageView.image = UIImage(data: imageData)
            }
            
        }
        
        if(VTClient.Count.downloaded == self.fetchedResultsController.fetchedObjects?.count){
            self.newCollection.alpha = 1
            self.newCollection.enabled = true
        }
        
        
        return cell
    }
    
    func configureCell(cell:CollectionViewCell,atIndexPath indexPath:NSIndexPath){
        
        if let _ = selectedCells.indexOf(indexPath){
            
            cell.cellImageView.alpha = 0.2
            newCollection.hidden = true
            removePictures.hidden = false
            
        }else{
            cell.cellImageView.alpha = 1.0
            newCollection.hidden = false
            removePictures.hidden = true
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
        
        if let index = selectedCells.indexOf(indexPath){
            selectedCells.removeAtIndex(index)
        }else{
            selectedCells.append(indexPath)
        }
        
        configureCell(cell, atIndexPath:indexPath)
        
    }
    
    
    
    // FETCHED RESULTS CODE
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertIndexPaths = [NSIndexPath]()
        deleteIndexPaths = [NSIndexPath]()
        changeIndexPaths = [NSIndexPath]()
    }
    
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        
        switch type{
        // called every time picture added to collection view
        case .Insert:
            insertIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deleteIndexPaths.append(indexPath!)
            break
        case .Update:
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

    
    
    // EXTRA FUNCTIONS
    
    @IBAction func getNewCollection(sender: UIButton) {
       
        //call function to delete all pcitures with completion handler
        deleteCurrentPictures(){
            () in
            
            // get new colleciton of pictures
            var boundingDictionary:[String:AnyObject] = [String:AnyObject]()
        
            let fetchBoxRequest = NSFetchRequest(entityName: "Box")
            let predicate = NSPredicate(format: "pin == %@", self.currentPin)
            fetchBoxRequest.predicate = predicate
        
            do{
                let fetchedEntity = try self.sharedContext.executeFetchRequest(fetchBoxRequest) as! [Box]
            
                boundingDictionary[Box.Keys.minLong] = fetchedEntity.first?.minLong
                boundingDictionary[Box.Keys.minLat] = fetchedEntity.first?.minLat
                boundingDictionary[Box.Keys.maxLong] = fetchedEntity.first?.maxLong
                boundingDictionary[Box.Keys.maxLat] = fetchedEntity.first?.maxLat
            
                var newPageNumber = fetchedEntity.first?.pageNumber as! Int
                newPageNumber++
                boundingDictionary[Box.Keys.pageNumber] = newPageNumber
                fetchedEntity.first?.pageNumber = newPageNumber as NSNumber
            
            }catch{
          
            }
        
        
            var localPathArray:[String] = []
            var urlArray:[NSURL] = []
          
            
            VTClient.sharedInstance().connectToFlickr(boundingDictionary){
                (result,photoID,error)in
            
                for(var i:Int = 0; i < photoID.count ; i++){
                    
                    // use returned imageURL path to save to core data
                    let fullPath = self.pathForImage(photoID[i] as! String)
                
                    localPathArray.append(fullPath)
                    let newURL = result[i] as! NSURL
                    urlArray.append(newURL)
                
                
                    // set up photo dictionary
                    var photoDic:[String:AnyObject] = [String:AnyObject]()
                
                    // add path to image in docs directory to core data
                    photoDic[Photo.Keys.imagePath] = fullPath
                    photoDic[Photo.Keys.savedToDirectory] = "No"
                                    
                    let newPhoto = Photo(dictionary: photoDic, context: self.sharedContext)
                    newPhoto.pin = self.currentPin
                
                
                
                    do{
                        try self.sharedContext.save()
                    }catch{
                        
                    }
                }// end of for loop
            
                VTClient.sharedInstance().getPictures(urlArray,pathArray: localPathArray)
          
            }
        }
    }
    
    
    func deleteCurrentPictures(completionHandler:() -> Void){
        
        VTClient.Count.downloaded = 0
        self.newCollection.alpha = 0.5
        self.newCollection.enabled = false
        
        
        let fetchedPhotoRequest = NSFetchRequest(entityName: "Photo")
        let photoPredicate = NSPredicate(format:"pin == %@", self.currentPin)
        fetchedPhotoRequest.predicate = photoPredicate
        
        
        do{
            let fetchedPhotos = try sharedContext.executeFetchRequest(fetchedPhotoRequest) as! [Photo]
            
            for photo in fetchedPhotos{
                sharedContext.deleteObject(photo)
            }
            
            do{
                try self.sharedContext.save()
            }catch{
                
            }
        }catch{
            
        }
        completionHandler()
        
    }
    
    
    
    @IBAction func removePictures(sender: UIButton) {
        
        // remove pictures using selected cells
        
        var photosToDelete = [Photo]()
        
        for indexPath in selectedCells{
            
            let fetchedPhoto = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            photosToDelete.append(fetchedPhoto)
        }
        
        for photo in photosToDelete{
            sharedContext.deleteObject(photo)
        }
        
        selectedCells = [NSIndexPath]()
        
        newCollection.hidden = false
        removePictures.hidden = true
    }
    
    
    func pathForImage(identifier:String)-> String{
        let url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent(identifier).path!
    }
 
}