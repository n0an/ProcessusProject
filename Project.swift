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
    
    var fullName: String {
        return "\(customer!) \(name!)"
    }

    // MARK: - CORE DATA ADDON FOR RELATIONSHIPS MANIPULATION
    
    func remove(workerObject person: Person) {
        mutableSetValue(forKey: "workers").remove(person)
    }
    
    func add(workerObject person: Person) {
        mutableSetValue(forKey: "workers").add(person)
    }

    
    // MARK: - PRIVATE METHODS
    
    fileprivate func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.shared.scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let number = notification.userInfo?["ProjectID"] as? Int, number == projectId {
                return notification
            }
        }
        
        return nil
    }

    
    // Deleting local notification before delete object
    override func prepareForDeletion() {
        if let notification = notificationForThisItem() {
            print("Removing existing notification \(notification)")
            
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
    
    
    
    // MARK: - PUBLIC METHODS
    
    func scheduleNotification() {
        
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Found an existing notification \(notification)")
            UIApplication.shared.cancelLocalNotification(notification)
        }
        
        if shouldRemind!.boolValue && dueDate!.compare(Date()) != .orderedAscending {
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate as Date?
            
            localNotification.timeZone = TimeZone.current
            
            localNotification.alertBody = name
            
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            localNotification.userInfo = ["ProjectID": projectId!.intValue]
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
            
            print("Scheduled notification \(localNotification) for projectId \(projectId!.intValue)")

        }
        
        
    }
    
    
    
}
