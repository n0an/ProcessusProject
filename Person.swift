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
    
    var fullName: String {
        return "\(firstName!) \(lastName!)"
    }

    // MARK: - CORE DATA ADDON FOR RELATIONSHIPS MANIPULATION

    func remove(projectObject project: Project) {
        mutableSetValue(forKey: "projects").remove(project)
    }
    
    func add(projectObject project: Project) {
        mutableSetValue(forKey: "projects").add(project)
    }
    
    
    
}
