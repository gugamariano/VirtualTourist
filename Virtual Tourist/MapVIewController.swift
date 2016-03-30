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
    var annotation = MKPointAnnotation()
    
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
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    //MARK: - PIN
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
    
    //when the user press for more than 0.5 secs, drop a pin on the map and query Flickr for photos for the location on the map
    func longPress(sender: UILongPressGestureRecognizer) {

        let touchLocation = sender.locationInView(mapView)
        let coordinate = mapView.convertPoint(touchLocation,toCoordinateFromView: mapView)

        let dic = ["latitude" : coordinate.latitude , "longitude" : coordinate.longitude]
        
        annotation.coordinate = coordinate
        
        switch (sender.state) {
        case .Began:
           
            mapView.addAnnotation(annotation)
            managedPin=Pin(dictionary: dic, context:self.sharedContext)
            
        case .Ended :
            mapView.removeAnnotation(annotation)
            
            managedPin.latitude=coordinate.latitude
            managedPin.longitude=coordinate.longitude
            
            mapView.addAnnotation(managedPin)
            

            CoreDataStackManager.sharedInstance().saveContext()

            
            self.managedPin.searchPhotos(false, didComplete: { (count) -> Void in
                
                
            })
            
            
        default:
            return
            
        }
    }
    
    //MARK: - mapView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
        
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "photoPin")
            
            pinAnnotationView.draggable = true
            pinAnnotationView.animatesDrop = true
            
            return pinAnnotationView
            
        }
        
        return nil
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let pin = view.annotation as! Pin
                
        showPhotoAlbumViewController(pin)
        
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

    //MARK: - Photo Album
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
    
    
    
    
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    
}




