//
//  ANDataManager.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import Foundation
import CoreData



class ANDataManager {
    
    static let sharedManager = ANDataManager()
    
    
    lazy var storesDirectory: NSURL = {
        
        let fm = NSFileManager.defaultManager()
        
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
//        return urls[urls.count-1] as NSURL
        return urls.last! as NSURL

    }()
    
    
    
    
    lazy var localStoreURL: NSURL = {
        let url = self.storesDirectory.URLByAppendingPathComponent("Processus.sqlite")
        return url
    }()
    
    
    
    lazy var modelURL: NSURL = {
        
        let bundle = NSBundle.mainBundle()
        
        if let url = bundle.URLForResource("Model", withExtension: "momd") {
            return url
        }
        print("CRITICAL - Managed Object Model file not found")
        
        abort()
    }()
    
    
    
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL:self.modelURL)!
    }()
    
    
    
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
    
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.localStoreURL, options: nil)
        } catch {
            print("Could not add the peristent store")
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var context: NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.coordinator
        
        return mainContext
    }()
    
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
    
    
    func addPerson(withFirstName firstName: String, lastName: String, email: String) {
        
        let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context) as! Person
        
        person.firstName = firstName
        person.lastName = lastName
        person.email = email
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Can't save context")
            abort()
        }
        
    }
    
    
}






