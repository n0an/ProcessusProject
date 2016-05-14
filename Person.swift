//
//  Person.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData


class Person: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func remove(projectObject project: Project) {
        mutableSetValueForKey("projects").removeObject(project)
    }
    
    func add(projectObject project: Project) {
        mutableSetValueForKey("projects").addObject(project)
    }
    
    
    
}
