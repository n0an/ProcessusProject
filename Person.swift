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

    // MARK: - CORE DATA ADDON FOR RELATIONSHIPS MANIPULATION

    func remove(projectObject project: Project) {
        mutableSetValueForKey("projects").removeObject(project)
    }
    
    func add(projectObject project: Project) {
        mutableSetValueForKey("projects").addObject(project)
    }
    
    
    
}
