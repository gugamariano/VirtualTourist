//
//  File.swift
//  FavoriteActors
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//
//  From the iOS Persistance and Core Data course material
//  I removed the in memory cache to follow the rubric as literally as possible
//  The identifier is path in the documents directory (It is also the Flickr photo id)

import UIKit

class ImageCache {
    
    struct Static {
        static let instance = ImageCache()
    }
    
       // MARK: Image retrieval
    
    func downloadImage(imageUrl: String, didComplete: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: imageUrl)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                print("download error for \(imageUrl)")
                didComplete(imageData: nil, error: error)
            } else {
                print("sucess for \(imageUrl)")                
                didComplete(imageData: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
    
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL!)!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        // If the image is nil, remove images from the cache
        if image == nil {
            
            do {
             try NSFileManager.defaultManager().removeItemAtPath(path)
                print("Photo removed \(identifier)")
            }catch{
                print("Error removing item for \(identifier)")
            }
            return
        }
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)

        data!.writeToFile(path, atomically: true)
    }
}
