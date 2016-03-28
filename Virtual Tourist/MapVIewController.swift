//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by antonio silva on 1/30/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    var managedPin:Pin!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate=self
        
        restoreMapRegion(true)
        restorePins()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        
        mapView.addGestureRecognizer(lpgr)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func restorePins(){
        
        let managedPin: [Pin] = fecthAllPins()
        
        for p in managedPin {
            
            mapView.addAnnotation(p)
            
        }
        
    }
    
    func fecthAllPins() -> [Pin] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch _ {
            print("catch")
            return [Pin]()
        }
    }
    
    
    func longPress(sender: UILongPressGestureRecognizer) {

        let touchLocation = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(touchLocation,toCoordinateFromView: mapView)

        let dic = ["latitude" : coordinate.latitude , "longitude" : coordinate.longitude]

        
        switch (sender.state) {
        case .Began:
            print("Began")
            
            managedPin=Pin(dictionary: dic, context:self.sharedContext)
            managedPin.latitude=coordinate.latitude
            managedPin.longitude=coordinate.longitude
            
        case .Changed :
            print("changed")
            
            managedPin.latitude=coordinate.latitude
            managedPin.longitude=coordinate.longitude
            
            
            CoreDataStackManager.sharedInstance().saveContext()

        case .Ended :

            print("Ended")
            
            mapView.addAnnotation(managedPin)
            
            dispatch_async(dispatch_get_main_queue()) {
                
                CoreDataStackManager.sharedInstance().saveContext()
                
                self.managedPin.searchPhotos(false, didComplete: { (count) -> Void in
                    print("loaded \(count) photos ")

                })
            }
            
            showPhotoAlbumViewController(self.managedPin)
            
            
        default:
            return
            
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var v : MKAnnotationView! = nil
        let ident = "pin"
        v = mapView.dequeueReusableAnnotationViewWithIdentifier(ident)
        
        if v == nil {
            v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ident)
        }
        
        v.annotation = annotation
        v.draggable = true
        return v
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        //mapView.deselectAnnotation(view.annotation, animated: false)
        
        let pin = view.annotation as! Pin
                
        showPhotoAlbumViewController(pin)
        
    }
    
    func showPhotoAlbumViewController(pin : Pin){
        
        let controller=storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController!
        controller.pin=pin
        
        
        showViewController(controller, sender: nil)
        
    }
    
    
    
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    
    
}




