//
//  VirtualTouristClient.swift
//  Virtual Tourist
//
//  Created by Nick Short on 19/12/2015.
//  Copyright © 2015 Nick Short. All rights reserved.
//

import Foundation



extension VirtualTouristClient{
    
     /*
    func repeatableTasks(parameters:[String:AnyObject],completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask{
        
        
        
        let baseURL = VirtualTouristClient.Constants.flickrURL
        
        let urlString = escapedParameters(parameters)
        
        
       
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
                completionHandler(result: result, error: error)
            }
                    
                
            }
        }
        
        task.resume()
        return task
    }
    
    */
    // escape parameters ready for http
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    //parse returned JSON
    
    func parseJSON(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
       
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSON", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
   
    
    
    
    
}