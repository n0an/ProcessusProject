//
//  Project+CoreDataProperties.swift
//  Processus
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project");
    }

    @NSManaged public var completedRatio: NSNumber?
    @NSManaged public var customer: String?
    @NSManaged public var descript: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var finished: NSNumber?
    @NSManaged public var finishedStatus: String?
    @NSManaged public var name: String?
    @NSManaged public var projectId: NSNumber?
    @NSManaged public var shouldRemind: NSNumber?
    @NSManaged public var state: NSNumber?
    @NSManaged public var workers: NSSet?

}

// MARK: Generated accessors for workers
extension Project {

    @objc(addWorkersObject:)
    @NSManaged public func addToWorkers(_ value: Person)

    @objc(removeWorkersObject:)
    @NSManaged public func removeFromWorkers(_ value: Person)

    @objc(addWorkers:)
    @NSManaged public func addToWorkers(_ values: NSSet)

    @objc(removeWorkers:)
    @NSManaged public func removeFromWorkers(_ values: NSSet)

}
