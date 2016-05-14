//
//  Project.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData


class Project: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    func remove(workerObject person: Person) {
        mutableSetValueForKey("workers").removeObject(person)
    }
    
    func add(workerObject person: Person) {
        mutableSetValueForKey("workers").addObject(person)
    }
    
    
}
