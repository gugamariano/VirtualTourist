//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by antonio silva on 1/31/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//

import Foundation


import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    
    
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    var totalLoaded:Int = 0

    private let sectionInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    var pin:Pin!
    
    
    @IBAction func newCollectionAction(sender: AnyObject) {
        
        
        self.pin.deletePhotos()
        
        pin.searchPhotos(true) { (numberFound) -> Void in
            self.showOrHideLabel()
            
        }
        
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notfications for image loading
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadAllPhotos:", name: Constants.Notifications.ALL_PHOTO_LOADED_NOTIFICATION, object: pin)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadPhoto:", name: Constants.Notifications.PHOTO_LOADED_NOTIFICATION, object: nil)
        
        mapView.addAnnotation(pin)
        centerMapOnLocation(pin.coordinate)


        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        do {
            try fetchedResultsController.performFetch()
            showOrHideLabel()
            
        } catch {
            print(error)
        }
        
    }
    
    func showOrHideLabel(){
        let count = fetchedResultsController.fetchedObjects?.count
        
        totalLoaded=0
        
        for photo in pin.photos!  {
            if let p = photo as? Photo where p.downloadStatus == .Loaded{
                totalLoaded++
            }
        }
        
        
        if(totalLoaded == count ) {
            newCollectionBtn.hidden=false
        }else{
            newCollectionBtn.hidden=true
        }
        
        if ( count > 0){
            noImagesLabel.hidden=true
            
        }else{
            noImagesLabel.hidden=false
        }
    
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    
    func didLoadAllPhotos(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            //self.collectionLabel.hidden = true
            //self.newCollectionButton.enabled = true
        }
    }
    
    // Each photo posts a notificaation when it is loaded
    func didLoadPhoto(photo: Photo) {
        
        totalLoaded++
        showOrHideLabel()
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView!.reloadData()
        }
    }

    
    
    
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    

  
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
    
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("flickrCell", forIndexPath: indexPath) as! PhotoCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        if let image = ImageCache.Static.instance.imageWithIdentifier(photo.file) {
            
            dispatch_async(dispatch_get_main_queue()) {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidden=true
            }
            
            photo.downloadStatus = .Loaded
            cell.photo.image=image
            
            
        } else if(photo.downloadStatus == .NotLoaded) {

            dispatch_async(dispatch_get_main_queue()) {
                cell.activityIndicator.hidden=false
                cell.activityIndicator.startAnimating()
            }
    
            
            photo.downloadStatus = .Loading
            
            getRemoteImage(cell, photo: photo)
            
        }
        
        
        return cell

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if photo.downloadStatus == .Loaded {
            totalLoaded--
            photo.deletePhoto(true)
            showOrHideLabel()
        }
    }

    
    
    func getRemoteImage(cell: PhotoCell, photo: Photo) {
            
        let task = ImageCache.Static.instance.downloadImage(photo.url!) { imageData, error in
            if imageData != nil {

                photo.downloadStatus = .Loaded
                
                let image = UIImage(data: imageData!)
                
                photo.saveImage(image!)
            
            } else {
                print("error downloading image \(error)")
                photo.downloadStatus = .NotLoaded
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    //photo.delete()
                }
            }
        }
        cell.taskToCancelifCellIsReused = task
    }

    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        
        
        collectionView!.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView!.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView!.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView!.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)    }

    
    
}


extension PhotoAlbumViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            
            return sectionInsets
            
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
        return CGSize(width: 100  , height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
   }

