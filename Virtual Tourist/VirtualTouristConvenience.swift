//
//  VirtualTouristConvenience.swift
//  Virtual Tourist
//
//  Created by Nick Short on 20/12/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import Foundation
import MapKit

class VirtualTouristClient:NSObject{
    
    let session = NSURLSession.sharedSession()    
    
    var imageData:String = ""
    
    
    func connectToFlickr(boundingBox:[String],completionHandler:(result: AnyObject!, error: NSError?) -> Void){
        
        //let newString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=cd74d032d76c10c8279060286d16c119&bbox=-123,47,-120,49&accuracy=1&format=json&nojsoncallback=1"   
        
        
        let bbox:String = boundingBox.joinWithSeparator(",")
                
        let parameters = [
            "method":VirtualTouristClient.Constants.searchMethod,
            "api_key":VirtualTouristClient.Constants.flickrAPI,
            "accuracy":VirtualTouristClient.Constants.accuracy,
            "format":VirtualTouristClient.Constants.format,
            "nojsoncallback":VirtualTouristClient.Constants.nojsoncallback,
            "bbox":bbox,
            "per_page":"20"
            
        ]            
        
        
         /*
        repeatableTasks(parameters){
            (result,error) in
            
            if let error = error{
                
                completionHandler(result:result,error:error)
                
            }else{
                if let result = result{
                    //print(result)
                    completionHandler(result:result,error: error)
                    
                    self.getPhotosFromFlickr(result as! [String : AnyObject]){
                       (result, error) in
                        
                   }
                }
            }
        }
         */
        
        let baseURL = VirtualTouristClient.Constants.flickrURL
        
        let urlString = VirtualTouristClient.sharedInstance().escapedParameters(parameters)
        
        
        
        let fullURL:String = "\(baseURL)\(urlString)"
        
        
        
        let URL = NSURL(string: fullURL)
        let request = NSMutableURLRequest(URL: URL!)
        
        
        
        let task = session.dataTaskWithRequest(request){
            (data, response, downloadError) in
            
            if let error = downloadError{
                // handle error
                completionHandler(result: response, error: error)
                
            }else{
                // process JSON
                VirtualTouristClient.sharedInstance().parseJSON(data!){
                    (result,error) in
                    
                    self.processReturnedData(result as! [String : AnyObject]){
                        (result,error) in
                        //TODO: create completion handler to send arrays back to view controller? or saved model class ready for displaying or saving to core data
                        
                        completionHandler(result:result,error:error)
                    }
                }
                
                
            }
        }
        
        task.resume()
        
        
        
        
    }
    
    
    func processReturnedData(result:[String:AnyObject],completionHandler:(result: AnyObject!, error: NSError?) -> Void){
        
        /*
        var photoOwnerArray:[AnyObject] = []
        var photoFarmArray:[AnyObject] = []
        var photoServerArray:[AnyObject] = []
        var photoIdArray:[AnyObject] = []
        var photoSecretArray:[AnyObject] = []
        */
        
        var imagePathArray:[String] = []
        
        let photos = result["photos"]
        
        if let photos = photos{
            let photo = photos["photo"]
            if let photo = photo{
                if let photo = photo{
                    
                    
                    
                    /*
                    for(var i = 0;i < photo.count;i++){
                        let photo1 = photo[i]
                        print(photo1)
                        
                        let currentImageString = "https://farm"
                        
                        //let photoOwnerValue = photo1["owner"]!
                        //photoOwnerArray.append(photoOwnerValue!)
                        
                        let photoFarmId = photo1["farm"]!
                        photoFarmArray.append(photoFarmId!)
                        
                        let photoServerId = photo1["server"]!
                        photoServerArray.append(photoServerId!)
                        
                        let photoIdValue = photo1["id"]!
                        photoIdArray.append(photoIdValue!)
                        
                        let photoSecret = photo1["secret"]!
                        photoSecretArray.append(photoSecret!)
                        
                        let currentImageString = "https://farm" + "\(photoFarmArray[i])" + ".staticflickr.com/" +  "\(photoServerArray[i])" + "/" + "\(photoIdArray[i])" + "_" + "\(photoSecretArray[i])" + ".jpg"
                        
                        imageDataArray.append(currentImageString)
                    }
                    */
                    
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
                        
                        
                        currentImageString += "_"
                        
                        let photoSecret = photo1["secret"]! as! String
                        currentImageString += photoSecret
                        
                        
                        currentImageString += ".jpg"
                        
                        imagePathArray.append(currentImageString)
                    }
                    
                   
                    
                   
                }
            }
        }
        
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to process data"
       
        
        //let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        let error:NSError = NSError(domain: "Your domain", code: 9999, userInfo: dict)
        
         // create completion handler to return arrays to connectToFlickr
        completionHandler(result: imagePathArray,error: error)
    }
    
    
    
        
    /* Current Image String
    
    "https://farm" + "\(photoFarmArray[i])" + ".staticflickr.com/" +  "\(photoServerArray[i])" + "/" + "\(photoIdArray[i])" + "_" + "\(photoSecretArray[i])" + ".jpg"
    
        
     https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg

     */
        
        
        
       
       
        
        
        
    
    
    class func sharedInstance() -> VirtualTouristClient {
        
        struct Singleton {
            static var sharedInstance = VirtualTouristClient()
        }
        
        return Singleton.sharedInstance
    }
    
}