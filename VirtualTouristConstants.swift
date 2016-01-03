//
//  VirtualTouristConstants.swift
//  Virtual Tourist
//
//  Created by Nick Short on 19/12/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import Foundation


extension VirtualTouristClient{
    
    struct Constants{
        
        static let flickrURL:String = "https://api.flickr.com/services/rest/"
        
        static let getPhotoURL:String = "https://www.flickr.com/photos/"
        static let searchMethod:String = "flickr.photos.search"
        
        
        // TODO: get photo method
        
        
        static let format:String = "json"
        static let nojsoncallback:String = "1"
        static let accuracy:String = "1"
        static let flickrAPI:String = "cd74d032d76c10c8279060286d16c119"
        //static let flickrSecret:String = "115bf720a67c6b33"
    }
    
    
    
}


// &accuracy=1&format=json&nojsoncallback=1
//let newString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=cd74d032d76c10c8279060286d16c119&bbox=-123,47,-120,49&accuracy=1&format=json&nojsoncallback=1"