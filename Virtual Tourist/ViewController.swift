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

class ViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var MapView: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MapView.delegate = self
        addToMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // create sharedContext variable
    lazy var sharedContext:NSManagedObjectContext = {
       return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // create map
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
    
    
    // create pin drop using tap and hold
    
    //have pin click open new view controller
}

