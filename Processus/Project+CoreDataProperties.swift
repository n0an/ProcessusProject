//
//  Project+CoreDataProperties.swift
//  
//
//  Created by Anton Novoselov on 07/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Project {

    @NSManaged var completedRatio: NSNumber?
    @NSManaged var customer: String?
    @NSManaged var descript: String?
    @NSManaged var dueDate: Date?
    @NSManaged var name: String?
    @NSManaged var projectId: NSNumber?
    @NSManaged var shouldRemind: NSNumber?
    @NSManaged var state: NSNumber?
    @NSManaged var finished: NSNumber?
    @NSManaged var finishedStatus: String?
    @NSManaged var workers: NSSet?

}
