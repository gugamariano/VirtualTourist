//
//  Photo.swift
//  Virtual Tourist
//
//  Created by antonio silva on 2/9/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//

import Foundation
import CoreData
import UIKit


enum DownloadStatus {
    case NotLoaded, Loading, Loaded
}

class Photo: NSManagedObject {

    var downloadStatus: DownloadStatus = .NotLoaded
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        url = dictionary[Constants.JSONKeys.URL] as? String
        file = dictionary[Constants.JSONKeys.File] as? String
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let image = ImageCache.Static.instance.imageWithIdentifier(file) {
            downloadStatus = .Loaded
        }
    }
    
    
    func deletePhoto(save:Bool) -> Void{
        
        ImageCache.Static.instance.storeImage(nil, withIdentifier: file!)
        
        managedObjectContext?.deleteObject(self)

        
        if(save){
            do{
                try managedObjectContext?.save()
                

            }catch{
                print ("error deleting photo \(file)")
            }
        }

        
    }
    
    func saveImage(image: UIImage) {
        
        ImageCache.Static.instance.storeImage(image, withIdentifier: file!)
        downloadStatus = .Loaded
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.PHOTO_LOADED_NOTIFICATION, object: self)
        
        print("Photo saved \(file)")
    }

    
    func getImage() -> UIImage?{
        
        var image:UIImage!

        
        let f=ImageCache.Static.instance.pathForIdentifier(file!)
        image = UIImage(named: f)
        
        return image
    
    }
    


}
