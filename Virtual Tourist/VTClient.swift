//
//  VTClient.swift
//  Virtual Tourist
//
//  Created by Nick Short on 20/01/2016.
//  Copyright © 2016 Nick Short. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VTClient:NSObject{
    
    let session = NSURLSession.sharedSession()
    
    lazy var sharedContext:NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    func connectToFlickr(boundingDictionary:[String:AnyObject],completionHandler:(result: AnyObject!,photoID:[AnyObject], error: NSError?) -> Void){
        
        
        //Turn dictionary data into string
        let bbox:String = "\(boundingDictionary[Box.Keys.minLong]!)" + "," +  "\(boundingDictionary[Box.Keys.minLat]!)" + "," + "\(boundingDictionary[Box.Keys.maxLong]!)" + "," + "\(boundingDictionary[Box.Keys.maxLat]!)"
        
        //Get page number from dictionary
        let pageNumber = boundingDictionary[Box.Keys.pageNumber]
        
        
        // setup parameters
        let parameters = [
            "method":VTClient.Constants.searchMethod,
            "api_key":VTClient.Constants.flickrAPI,
            "accuracy":VTClient.Constants.accuracy,
            "format":VTClient.Constants.format,
            "nojsoncallback":VTClient.Constants.nojsoncallback,
            "bbox":bbox,
            "per_page":"21",
            "page":pageNumber
        ]
        
        
        // create URL
        let baseURL = VTClient.Constants.flickrURL
        let urlString = VTClient.sharedInstance().escapedParameters(parameters as! [String : AnyObject])
        let fullURL:String = "\(baseURL)\(urlString)"
        let URL = NSURL(string: fullURL)
        
        
        let request = NSMutableURLRequest(URL: URL!)
        
        // Send request
        let task = session.dataTaskWithRequest(request){
            (data, response, downloadError) in
            
            if let error = downloadError{
                let photoID = [AnyObject]()
                
                completionHandler(result: response,photoID:photoID,error: error)
                
            }else{
                // process JSON
                VTClient.sharedInstance().parseJSON(data!){
                    (result,error) in
                    
                     self.processReturnedData(result as! [String : AnyObject]){
                        (result,photoID,error) in
                        
                        completionHandler(result:result,photoID:photoID,error:error)
                    }
                }
            }
        }
        task.resume()
    }
    
    // process JSON
    func processReturnedData(result:[String:AnyObject],completionHandler:(result: [NSURL],photoIDs:[AnyObject], error: NSError?) -> Void){
        
        var imageURLArray:[NSURL] = []
        var photoIdArray:[AnyObject] = []
        
        let photos = result["photos"]
        if let photos = photos{
            let photo = photos["photo"]
            if let photo = photo{
                if let photo = photo{
                    
                    for(var i = 0;i < photo.count;i++){
                        let photo1 = photo[i]
                        
                        var currentImageString = "https://farm"
                        
                        let photoFarmId = photo1["farm"]!
                        currentImageString += "\(photoFarmId!)"
                        currentImageString += ".staticflickr.com/"
                        
                        let photoServerId = photo1["server"]! as! String
                        currentImageString += photoServerId
                        currentImageString += "/"
                        
                        let photoIdValue = photo1["id"]! as! String
                        currentImageString += photoIdValue
                        photoIdArray.append(photoIdValue)
                        currentImageString += "_"
                        
                        let photoSecret = photo1["secret"]! as! String
                        currentImageString += photoSecret
                        currentImageString += ".jpg"
                        
                        let url = NSURL(string:currentImageString)
                        imageURLArray.append(url!)
                    }
                }
            }
       }
        
        // create completion handler to return arrays to connectToFlickr
        completionHandler(result: imageURLArray,photoIDs:photoIdArray,error: nil)
        
    }
    
    
    // Get pictures
    func getPictures(urlArray:[NSURL],pathArray:[String]){
        
        for(var i:Int = 0; i < urlArray.count; i++){
            
            
            let imageData = NSData(contentsOfURL:urlArray[i])
            let newImage = UIImage(data: imageData!)
            
            UIImageJPEGRepresentation(newImage!,1.0)?.writeToFile(pathArray[i], atomically: true)
           
            let predicate = NSPredicate(format:"imagePath == %@", pathArray[i])
            
            let fetchRequest = NSFetchRequest(entityName: "Photo")
            fetchRequest.predicate = predicate
            
            do{
                
                let fetchedEntities = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Photo]
                fetchedEntities.first!.savedToDirectory = "Yes"
                
                // increment count variable for collection view controller use
                var downloadCount = VTClient.Count.downloaded!
                downloadCount++
                VTClient.Count.downloaded = downloadCount
                
            }catch{
                
            }
            
            
            
            
        }
        // save context
            do{
                try self.sharedContext.save()
            }catch{
                
            }
        
        
    }
    
    // create singleton
    class func sharedInstance() -> VTClient {
        
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        
        return Singleton.sharedInstance
    }
    
}
