//
//  MyRestaurantsTableViewController.swift
//  MyRestaurants
//
//  Created by Anton Novoselov on 24/03/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


class ANCoalleguesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    
    var fetchedResultController: NSFetchedResultsController!
    var myRestaurants: [Person] = []
    
    var searchController: UISearchController!
    
    var searchResultsArray: [Person] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
//        tableView.tableFooterView = UIView(frame: CGRectZero) // FAIL WITH SEARCHCONTROLLER

        
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Loading data from DB
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]
        
        
        let managedObjectContext = ANDataManager.sharedManager.context
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        
        var error: NSError?
        var result: Bool
        do {
            try fetchedResultController.performFetch()
            result = true
        } catch let error1 as NSError {
            error = error1
            result = false
        }
        
        myRestaurants = fetchedResultController.fetchedObjects as! [Person]
        
        if result == false {
            print("error occured: \(error?.localizedDescription)")
        }

        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.whiteColor()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - SEARCH CONTROLLER METHODS
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContentFor(searchText!)
        
        tableView.reloadData()
        
    }
    
    
    func filterContentFor(searchText: String) {
        searchResultsArray = myRestaurants.filter({ (restaurant: Person) -> Bool in
            let matchedName = restaurant.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
            
            return matchedName != nil
        })
    }
    
    
    
    // MARK: - NSFetchedResultsController

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            tableView.reloadData()
        }
        
        myRestaurants = controller.fetchedObjects as! [Person]
        
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            return searchResultsArray.count
        }
        
        
        return myRestaurants.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ANPersonCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ANPersonCell
        
        let restaurant = (searchController.active) ? searchResultsArray[indexPath.row] : myRestaurants[indexPath.row]
        
        if let firstName = restaurant.firstName, lastName = restaurant.lastName {
            cell.fullNameLabel.text = "\(firstName) \(lastName)"

        }
        
        if let imageData = restaurant.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        
        if let projectsCount = restaurant.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }

        
        
        cell.tintColor = UIColor.redColor()
        
        return cell
    }
    
    
    
    
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if searchController.active {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
         let actionMenu = UIAlertController(title: nil, message: "Что делаем?", preferredStyle: .ActionSheet)
         
         
         let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
         actionMenu.addAction(cancelAction)
         
         
         let iHaveBeenThereAction = UIAlertAction(title: "Я тут был", style: .Default, handler: {(action: UIAlertAction!) -> Void in
         
         let cell = tableView.cellForRowAtIndexPath(indexPath)
         cell?.accessoryType = .Checkmark
         cell!.accessoryView = UIImageView(image: UIImage(named: "check-icon-green"))
         self.restaurantAlreadyVisited[indexPath.row] = true
         
         })
         
         let iHaveNeverBeenThereAction = UIAlertAction(title: "Я тут не был", style: .Default, handler: {(action: UIAlertAction!) -> Void in
         
         let cell = tableView.cellForRowAtIndexPath(indexPath)
         cell?.accessoryType = .None
         cell!.accessoryView = nil
         self.restaurantAlreadyVisited[indexPath.row] = false
         
         })
         
         let cell = tableView.cellForRowAtIndexPath(indexPath)
         
         if cell?.accessoryType == .Checkmark {
         actionMenu.addAction(iHaveNeverBeenThereAction)
         } else {
         actionMenu.addAction(iHaveBeenThereAction)
         }
         
         let callActionHandler = {(action: UIAlertAction!) -> Void in
         
         let warningMessage = UIAlertController(title: "Service is not available", message: "Call can not be made now", preferredStyle: .Alert)
         
         let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
         
         warningMessage.addAction(okAction)
         
         self.presentViewController(warningMessage, animated: true, completion: nil)
         
         }
         
         let callAction = UIAlertAction(title: "Звоним 1234567", style: .Default, handler: callActionHandler)
         actionMenu.addAction(callAction)
         
         
         self.presentViewController(actionMenu, animated: true, completion: nil)
         
         */
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let allShareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Поделиться") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            
            let allShareActionMenu = UIAlertController(title: nil, message: "Поделиться через", preferredStyle: .ActionSheet)
            
            let emailShareAction = UIAlertAction(title: "Email", style: .Default, handler: nil)
            let facebookShareAction = UIAlertAction(title: "Facebook", style: .Default, handler: nil)
            let vkShareAction = UIAlertAction(title: "VK", style: .Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
            
            allShareActionMenu.addAction(emailShareAction)
            allShareActionMenu.addAction(facebookShareAction)
            allShareActionMenu.addAction(vkShareAction)
            allShareActionMenu.addAction(cancelAction)
            
            
            self.presentViewController(allShareActionMenu, animated: true, completion: nil)
            
        }
        
        // Creating our own Delete button
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Удалить") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            let restaurantToRemove = self.fetchedResultController.objectAtIndexPath(indexPath) as! Person
            
            
            let managedObjectContext = ANDataManager.sharedManager.context
            
            managedObjectContext.deleteObject(restaurantToRemove)
            
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                    abort()
                }
            }

            
            
            
            
        }
        
        allShareAction.backgroundColor = UIColor(red: 184/255, green: 226/255, blue: 181/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, allShareAction]
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDetailsSegue" {
//            if let indexPath = self.tableView.indexPathForSelectedRow {
//                let destinationVC = segue.destinationViewController as! DetailsViewController
//                
//                destinationVC.restaurant = (searchController.active) ? searchResultsArray[indexPath.row] : myRestaurants[indexPath.row]
//                
//            }
//        }
//    }
    
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "showPersonDetails" else {return}
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        let destinationVC = segue.destinationViewController as! ANPersonDetailsViewController
        
        
        
//        guard let person = fetchedResultsController?.objectAtIndexPath(indexPath) as? Person else {return}
        
        
        destinationVC.delegate = self
        
        destinationVC.person = searchController.active ? searchResultsArray[indexPath.row] : myRestaurants[indexPath.row]
        
    }

    
    
    
    
    
}



// MARK: - ANPersonDetailsVCDelegate

extension ANCoalleguesTableViewController: ANPersonDetailsVCDelegate {
    func personEditingDidEndForPerson(person: Person) {
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
    }
    
}






