//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by antonio silva on 2/9/16.
//  Copyright © 2016 antonio silva. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var page: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSSet?
    

}
