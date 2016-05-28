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
    
    // MARK: - ATTRIBUTES
    
    static let sharedManager = ANDataManager()
    
    
    lazy var storesDirectory: NSURL = {
        
        let fm = NSFileManager.defaultManager()
        
        let urls = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
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
    
    
    // MARK: - PUBLIC METHODS
    
    func saveContext () {
        print("saveContext ()")

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
//    func addPerson(withFirstName firstName: String, lastName: String, email: String) {
//        
//        let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context) as! Person
//        
//        person.firstName = firstName
//        person.lastName = lastName
//        person.email = email
//        
//        guard context.hasChanges else { return }
//        
//        do {
//            try context.save()
//        } catch {
//            print("Can't save context")
//            abort()
//        }
//        
//    }
    
    
    func getAllObjectsForName(name: String) -> [AnyObject] {
        
        let request = NSFetchRequest()
        
        let description = NSEntityDescription()
        description.name = name
        
        request.entity = description
        
        var resultArray: [AnyObject] = []
        
        do {
            resultArray = try context.executeFetchRequest(request)
        } catch {
            print("error")
        }
        
        return resultArray
    }
    
    func printArray(array: [AnyObject]) {
        
        for object in array {
            
            if object is Person {
                let person = object as! Person
                print("Person: \(person.firstName)")
            } else if object is Project {
                let project = object as! Project
                print("Project: \(project.customer)")
            }
            
            
        }
        
    }
    
    
    func showAllPeople() {
        
        printArray(getAllObjectsForName("Person"))
        
        
    }
    
    func showAllProjects() {
        printArray(getAllObjectsForName("Project"))
    }
    
    
    
    
}






