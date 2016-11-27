//
//  Person+CoreDataClass.swift
//  Processus
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData


public class Person: NSManagedObject {

    var fullName: String {
        return "\(firstName!) \(lastName!)"
    }
    
    
}
