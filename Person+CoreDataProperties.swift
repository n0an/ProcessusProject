//
//  Person+CoreDataProperties.swift
//  Processus
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person");
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var image: NSData?
    @NSManaged public var lastName: String?
    @NSManaged public var personId: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var projects: NSSet?

}

// MARK: Generated accessors for projects
extension Person {

    @objc(addProjectsObject:)
    @NSManaged public func addToProjects(_ value: Project)

    @objc(removeProjectsObject:)
    @NSManaged public func removeFromProjects(_ value: Project)

    @objc(addProjects:)
    @NSManaged public func addToProjects(_ values: NSSet)

    @objc(removeProjects:)
    @NSManaged public func removeFromProjects(_ values: NSSet)

}
