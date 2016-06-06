//
//  FinishedStatus+CoreDataProperties.swift
//  
//
//  Created by Anton Novoselov on 06/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FinishedStatus {

    @NSManaged var success: NSNumber?
    @NSManaged var project: NSSet?

}
