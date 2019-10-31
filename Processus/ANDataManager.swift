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
    
    lazy var storesDirectory: URL = {
        
        let fm = FileManager.default
        
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        return urls.last! as URL

    }()
    
    lazy var localStoreURL: URL = {
        let url = self.storesDirectory.appendingPathComponent("Processus.sqlite")
        return url
    }()
    
    
    lazy var modelURL: URL = {
        
        let bundle = Bundle.main
        
        if let url = bundle.url(forResource: "Model", withExtension: "momd") {
            return url
        }
        print("CRITICAL - Managed Object Model file not found")
        
        abort()
    }()
    
    
    
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf:self.modelURL)!
    }()
    
    
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
    
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.localStoreURL, options: nil)
        } catch {
            print("Could not add the peristent store")
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var context: NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.coordinator
        
        return mainContext
    }()
    
    
    // MARK: - PRIVATE METHODS
    
    fileprivate func getAllObjectsForName(_ name: String) -> [AnyObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        let description = NSEntityDescription()
        description.name = name
        
        request.entity = description
        
        var resultArray: [AnyObject] = []
        
        do {
            resultArray = try context.fetch(request)
        } catch {
            print("error")
        }
        
        return resultArray
    }
    
    fileprivate func printArray(_ array: [AnyObject]) {
        
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

    
    // MARK: - PUBLIC METHODS
    
    func saveContext () {
//        print("saveContext ()")

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
    
    
    func showAllPeople() {
        printArray(getAllObjectsForName("Person"))
    }
    
    func showAllProjects() {
        printArray(getAllObjectsForName("Project"))
    }
    
    
    func nextProjectItemID() -> Int {
        
        let allProjects = getAllObjectsForName("Project") as! [Project]
        
        var itemID = 0
        
        for project in allProjects {

            if let numProjectID = project.projectId?.intValue {
                
                if numProjectID > itemID {
                    itemID = numProjectID
                }
            }
        }
        
        return itemID + 1
    }
    
    
    
    
}






