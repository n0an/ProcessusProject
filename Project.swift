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

    // MARK: - CORE DATA ADDON FOR RELATIONSHIPS MANIPULATION
    
    func remove(workerObject person: Person) {
        mutableSetValueForKey("workers").removeObject(person)
    }
    
    func add(workerObject person: Person) {
        mutableSetValueForKey("workers").addObject(person)
    }

    
    // MARK: - PRIVATE METHODS
    
    private func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let number = notification.userInfo?["ProjectID"] as? Int where number == projectId {
                return notification
            }
        }
        
        return nil
    }

    
    // Deleting local notification before delete object
    override func prepareForDeletion() {
        if let notification = notificationForThisItem() {
            print("Removing existing notification \(notification)")
            
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    
    
    // MARK: - PUBLIC METHODS
    
    func scheduleNotification() {
        
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Found an existing notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
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
