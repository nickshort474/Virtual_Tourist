//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Nick Short on 08/01/2016.
//  Copyright © 2016 Nick Short. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation:NSObject,MKAnnotation{
    
    var pin:Pin!
    var coordinate:CLLocationCoordinate2D
    
    
    init(pin:Pin!,coords:CLLocationCoordinate2D){
        self.coordinate = coords
        self.pin = pin
    }
    
   
    
    
}