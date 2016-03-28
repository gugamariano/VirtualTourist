//
//  Pin.swift
//  Virtual Tourist
//
//  Created by antonio silva on 2/3/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        latitude = dictionary["latitude"] as? NSNumber
        longitude = dictionary["longitude"] as? NSNumber
        page = 1
        
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude as! Double, longitude as! Double)
        }
    }
    
    func deletePhotos() -> Void{
        
        print("total \(photos?.count)")
        for photo in photos!  {

            if let p=photo as? Photo{
                p.deletePhoto(false)
               
            }
        }
        
        do{
            try managedObjectContext?.save()
        }catch{
            print("error deleting photo")
        }
    
    }
    
    
    func searchPhotos(nextPage:Bool, didComplete: (numberFound: Int) -> Void) {
        
        var count:Int = 0
        var p:Int=1
        
        if(nextPage){
            p=(page?.integerValue)!
            p++
        }
        
        let cord=CLLocationCoordinate2D(latitude:latitude as! Double, longitude: longitude as! Double)
        
        VirtualTouristClient.sharedInstance().searchByLatLon(p, coordinate: cord,completionHandler: { (data) -> Void in
            
            if let photoData = data!["photos"] as? [String: AnyObject],
                let photosFlickr = photoData["photo"] as? [AnyObject]
            {
            
                
                for photo in photosFlickr {

                    let file = photo["id"] as! String
                    let url = photo["url_m"] as! String
                    let dict = ["url": url, "file": file]
                    
                    let p = Photo(dictionary: dict, context: self.managedObjectContext!)
                    p.pin=self
                
                    
                    do {
                    
                        try self.managedObjectContext?.save()
                        count++;

                    }catch{
                        print("error saving photo")
                    }
                    
                }
                
                didComplete(numberFound:count)


            }

            
            
        })

    }
    
    
    
    
    
    
}
