//
//  Project+CoreDataProperties.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Project {

    @NSManaged var customer: String?
    @NSManaged var descript: String?
    @NSManaged var dueDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var projectId: String?
    @NSManaged var state: NSNumber?
    @NSManaged var completedRatio: NSNumber?
    @NSManaged var workers: NSSet?

}
