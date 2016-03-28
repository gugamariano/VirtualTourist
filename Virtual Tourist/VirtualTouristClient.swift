//
//  VirtualTouristClient.swift
//  Virtual Tourist
//
//  Created by antonio silva on 2/8/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//

import Foundation
import MapKit

class VirtualTouristClient: NSObject {
    
    var session: NSURLSession
    
    override init(){
        session = NSURLSession.sharedSession()
        super.init()
        
    }
    
    
    func searchByLatLon(withPageNumber:Int, coordinate:CLLocationCoordinate2D, completionHandler:(NSDictionary?) -> Void ) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(coordinate),
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        searchImages(methodParameters,withPageNumber: withPageNumber, completionHandler:completionHandler)
        
    }
    
    private func bboxString(coordinate:CLLocationCoordinate2D) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(coordinate.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(coordinate.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(coordinate.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(coordinate.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    
    
    // MARK: Flickr API
    
    private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject],completionHandler:(NSDictionary?) -> Void) {
        
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            self.searchImages(methodParameters, withPageNumber: 1, completionHandler: completionHandler)
        }
        
        // start the task!
        task.resume()
    }
    
    private func searchImages(var methodParameters: [String:AnyObject], withPageNumber: Int, completionHandler:(NSDictionary?) -> Void) {
        
        // add the page to the method's parameters
        methodParameters[Constants.FlickrParameterKeys.Page] = withPageNumber
        
        // add the page to the method's parameters
        methodParameters[Constants.FlickrParameterKeys.Per_Page] = Constants.FlickrParameterValues.MAX_PER_PAGE
        
        // create session and request
        let session = NSURLSession.sharedSession()
        let request = NSURLRequest(URL: flickrURLFromParameters(methodParameters))
        
        // create network request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                
                //TODO
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: NSDictionary!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String where stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let _ = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            completionHandler(parsedResult)
        
        }
        
        // start the task!
        task.resume()
    }
    
    
    
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(result: parsedResult, error: nil)
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
    }
    
    
    //Utility to make a request and parse the resulted json if succeed. otherwise return the given error for the completionHandler
    func makeRequest(req: NSMutableURLRequest, subset:Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var errString:String = ""
        
        let task = session.dataTaskWithRequest(req) { data, response, error in
            
            guard (error == nil) else {
                errString = "There was an error with your request: \(error)"
                NSLog("Error making a request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: 1, userInfo:[NSLocalizedDescriptionKey: errString]))
                return
            }
            
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                var code=2
                if let response = response as? NSHTTPURLResponse {
                    if(response.statusCode == 403){
                        code=403
                    }
                    errString = "Your request returned an invalid response! Status code: \(code)!"
                    
                    
                } else if let response = response {
                    errString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errString = "Your request returned an invalid response!"
                }
                
                NSLog("Error making a request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: code, userInfo:nil))
                
                return
            }
            
            
            guard let data = data else {
                errString = "No data was returned by the request!"
                NSLog("Error getting data request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: 3, userInfo:[NSLocalizedDescriptionKey: errString]))
                return
            }
            
            
            let newData = data.subdataWithRange(NSMakeRange(subset, data.length - subset)) /* subset response data! */
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
        
        task.resume()
        
    }
    
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    
    //return a singleton instance for this client
    class func sharedInstance() -> VirtualTouristClient {
        
        struct Singleton {
            static var sharedInstance = VirtualTouristClient()
        }
        
        return Singleton.sharedInstance
    }
    
}