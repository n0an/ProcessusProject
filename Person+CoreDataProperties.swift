//
//  Person+CoreDataProperties.swift
//  Processus
//
//  Created by Anton Novoselov on 28/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var email: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var personId: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var image: Data?
    @NSManaged var projects: NSSet?

}
