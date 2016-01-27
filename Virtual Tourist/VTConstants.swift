//
//  VTConstants.swift
//  Virtual Tourist
//
//  Created by Nick Short on 20/01/2016.
//  Copyright © 2016 Nick Short. All rights reserved.
//

import Foundation


extension VTClient{
    
    struct Constants{
        
        static let flickrURL:String = "https://api.flickr.com/services/rest/"
        static let searchMethod:String = "flickr.photos.search"
        static let format:String = "json"
        static let nojsoncallback:String = "1"
        static let accuracy:String = "1"
        static let flickrAPI:String = "cd74d032d76c10c8279060286d16c119"
        
    }
    
    struct Count{
        static var downloaded:Int = 0
    }
    
}
