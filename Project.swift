//
//  Project.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class Project: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    
    func remove(workerObject person: Person) {
        mutableSetValueForKey("workers").removeObject(person)
    }
    
    func add(workerObject person: Person) {
        mutableSetValueForKey("workers").addObject(person)
    }
    
    
    func scheduleNotification() {
        if shouldRemind!.boolValue && dueDate!.compare(NSDate()) != .OrderedAscending {
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            localNotification.alertBody = name
            
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            localNotification.userInfo = ["ProjectID": projectId!.integerValue]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            print("Scheduled notification \(localNotification) for projectId \(projectId!.integerValue)")
            
            
            
            
            
        }
        
        
    }
    
    
    
}
