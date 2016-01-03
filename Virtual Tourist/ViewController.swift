//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Nick Short on 22/11/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController, MKMapViewDelegate,UIGestureRecognizerDelegate,NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var MapView: MKMapView!
    
    
    
    var annotations = [MKPointAnnotation]()
    var pinArray:[Pin]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MapView.delegate = self
        
        //let singleTap:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addPinToMap:")
        let smallTap:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action:"addNewPinToMap:")
        //smallTap.minimumPressDuration = 1
        smallTap.numberOfTouchesRequired = 1
        smallTap.delegate = self
        
        MapView.addGestureRecognizer(smallTap)
        
        
        
        
        
        /* fecthResultsController code
        var error:NSError?
        
        do{
            try fetchedResultsController.performFetch()
        }catch let error1 as NSError{
            error = error1
        }
        
        if let error = error{
            print("error performing fetch: \(error)")
        }
        */
        
        
        
        pinArray = gatherPersistedPins()
        
        addPersistedPinsToMap()
        
        /*
            print(pinArray[0])
            print(pinArray[0].longitude)
            print(pinArray[0].latitude)
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // create sharedContext variable
    lazy var sharedContext:NSManagedObjectContext = {
       return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    /*
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    */
    
    func gatherPersistedPins() -> [Pin]{
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do{
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        }catch let error as NSError{
            print("Error in addPersistedPins(): \(error)")
            return [Pin]()
        }
        
        
        //let pin = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(index: 0)) as! Pin
        //let currentPin = fetchedResultsController.fetchedObjects![0]
        //print(pin)
       //print(pin.longitude)
    }
    
    func addPersistedPinsToMap(){
        
        for(var i:Int = 0; i < pinArray.count; i++){
            let pinCoords:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pinArray[i].latitude,pinArray[i].longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinCoords
            annotation.title = "Persisted Pin"
            self.MapView.addAnnotation(annotation)
        }
        
        
    }
    
    
    func addNewPinToMap(gestureRecognizer:UIGestureRecognizer){
        
        
        let tapPoint:CGPoint = gestureRecognizer.locationInView(MapView)
        let touchCoords:CLLocationCoordinate2D = MapView.convertPoint(tapPoint, toCoordinateFromView: MapView)
        
        
        // create Pin instance
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchCoords
        annotation.title = "TBD"
        self.MapView.addAnnotation(annotation)
        
        //TODO: Save Pin to core data
        var pinDic:[String:AnyObject] = [String:AnyObject]()
        
        
        pinDic[Pin.Keys.latitude] = touchCoords.latitude
        pinDic[Pin.Keys.longitude] = touchCoords.longitude
       
        
        dispatch_async(dispatch_get_main_queue()){
            let newPin = Pin(dictionary: pinDic, context: self.sharedContext)
            
            do{
                try self.sharedContext.save()
                
            }catch let error as NSError{
                print("error saving context: \(error.localizedDescription)")
            }
        }
        
        
        
        //CoreDataStackManager.sharedInstance().saveContext()
        
        
        var boundingBox:[String] = [String]()
        boundingBox.append(String(touchCoords.latitude - 1.0))
        boundingBox.append(String(touchCoords.longitude - 1.0))
        boundingBox.append(String(touchCoords.latitude + 1.0))
        boundingBox.append(String(touchCoords.longitude + 1.0))
        
        
        
        VirtualTouristClient.sharedInstance().connectToFlickr(boundingBox){
            (result,error) in
            
            print("The result is:\(result)")
            
            for(var i:Int = 0; i < result.count ; i++){
                var photoDic:[String:AnyObject] = [String:AnyObject]()
                photoDic[Photo.Keys.imagePath] = result[i]
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    let newPhoto = Photo(dictionary: photoDic, context: self.sharedContext)
                    
                    do{
                        try self.sharedContext.save()
                        
                    }catch let error as NSError{
                        print("error saving context: \(error.localizedDescription)")
                    }
                }
                
            }
            //TODO: add photo results to core data ready to be fetched from collection controller
            
            
            /*
            
            
            
            
            //photoDic[Photo.Keys.title] = touchCoords.longitude
            
            dispatch_async(dispatch_get_main_queue()){
                
                let newPhoto = Photo(dictionary: photoDic, context: self.sharedContext)
                
                do{
                    try self.sharedContext.save()
                    
                }catch let error as NSError{
                    print("error saving context: \(error.localizedDescription)")
                }
            }
            */
        }
        
    }
    
    
    
    // create map
    /*
    
    func addToMap(){
        
       
        let lat = CLLocationDegrees(52)
        let long = CLLocationDegrees(0.5)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Hello"
        annotation.subtitle = "info here"
        
        self.annotations.append(annotation)
        print(annotations)
        self.MapView.addAnnotations(self.annotations)
    }
    */
    
    // TODO: Change code to segue to collection view controller with map
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            print("annotation clicked")
            
            //let app = UIApplication.sharedApplication()
            //app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
            
            
            // TODO: segue to collection view controller
            
        }
        
    }
    
    
    
    // create pin drop using tap and hold
    
    //have pin click open new view controller
}

