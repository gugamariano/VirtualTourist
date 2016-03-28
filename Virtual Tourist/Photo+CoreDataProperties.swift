//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var file: String?
    @NSManaged var url: String?
    @NSManaged var pin: Pin?

}
