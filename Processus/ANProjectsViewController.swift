//
//  ANProjectsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData
import Parse


class ANProjectsViewController: UIViewController {

    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - ATTRIBUTES
    
    var searchController: UISearchController!

    private var fetchedResultsController: NSFetchedResultsController!
    
    var searchResultsArray: [Project] = []
    
    var myProjects: [Project] = []
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
//        navigationItem.leftBarButtonItem = editButtonItem()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
//        tableView.tableFooterView = UIView(frame: CGRectZero) // FAIL WITH SEARCHCONTROLLER

        
        let fetchRequest = NSFetchRequest(entityName: "Project")
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        let predicate = NSPredicate(format: "finished == false")
        
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print("There was a problem fetching.")
        }
        
        myProjects = fetchedResultsController.fetchedObjects as! [Project]
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.whiteColor()

    }
    
    
    
    
    // MARK: - HELPER METHODS
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func unwindBackToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func addProjectPressed(sender: UIBarButtonItem) {
        
        print("addProjectPressed")
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.delegate = self
            
        } else if segue.identifier == "showProjectDetails" {
            
            
            // === Variant - go directly to ANNewProjectTableViewController, withod IntermediateVC ===
            /*
             let navigationController = segue.destinationViewController as! UINavigationController
             
             let controller = navigationController.topViewController as! ANNewProjectTableViewController
             
             if let clickedIndexPath = tableView.indexPathForCell(sender as! ANPersonProjectCell) {
             guard let project = fetchedResultsController?.objectAtIndexPath(clickedIndexPath) as? Project else {return}
             
             controller.itemToEdit = project
             }
             */
            
            
            let destinationVC = segue.destinationViewController as! ANProjectDetailsViewController
            
            destinationVC.delegate = self
            
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            guard let project = fetchedResultsController?.objectAtIndexPath(indexPath) as? Project else {return}
            
            destinationVC.project = project
            
        }
        
        
    }


}




// MARK: - UITableViewDataSource
extension ANProjectsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            return searchResultsArray.count
        }
        
        return myProjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ANPersonProjectCell
        
        
        let project = searchController.active ? searchResultsArray[indexPath.row] : myProjects[indexPath.row]
        
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(project.dueDate!)
        
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)
        
     
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANProjectsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
//        guard let project = fetchedResultsController?.objectAtIndexPath(indexPath) as? Project else {return}
//        
//        if editingStyle == .Delete {
//            let context = ANDataManager.sharedManager.context
//            context.deleteObject(project)
//            
//            ANDataManager.sharedManager.saveContext()
//        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if searchController.active {
            return false
        }
        
        return true
    }

    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let finishAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Finish") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            let finishActionMenu = UIAlertController(title: nil, message: "Project finished:", preferredStyle: .ActionSheet)
            
            let finishSuccessAction = UIAlertAction(title: "Success", style: .Default) { (action: UIAlertAction) in
                print("FINISH TEST")
                
                let projectToFinish = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Project
                
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Success.rawValue
                
                ANDataManager.sharedManager.saveContext()
            }
            
            

            let finishFailureAction = UIAlertAction(title: "Failure", style: .Default, handler: { (action: UIAlertAction) in
                print("FAILURE TEST")
                
                let projectToFinish = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Project
                
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Failure.rawValue
                
                ANDataManager.sharedManager.saveContext()
            })
            
            

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            finishActionMenu.addAction(finishFailureAction)

            finishActionMenu.addAction(cancelAction)
            
            
            self.presentViewController(finishActionMenu, animated: true, completion: nil)
        }
        
        // Creating our own Delete button
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            
            SweetAlert().showAlert("Are you sure?", subTitle: "Project will be permanently deleted!", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, delete it!", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    print("Cancel Button  Pressed", terminator: "")
                }
                else {
                    
                    let projectToRemove = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Project
                    
                    
                    let managedObjectContext = ANDataManager.sharedManager.context
                    
                    managedObjectContext.deleteObject(projectToRemove)
                    
                    if managedObjectContext.hasChanges {
                        do {
                            try managedObjectContext.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                            abort()
                        }
                    }
                    
                    SweetAlert().showAlert("Deleted!", subTitle: "Project has been deleted!", style: AlertStyle.Success)
                }
            }
            
        }
        
        finishAction.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 181/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, finishAction]
        
    }
    
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension ANProjectsViewController: NSFetchedResultsControllerDelegate {
    
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
        
        myProjects = controller.fetchedObjects as! [Project]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}




// MARK: - UISearchResultsUpdating

extension ANProjectsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContentFor(searchText!)
        
        tableView.reloadData()
    }
    
    func filterContentFor(searchText: String) {
        
        searchResultsArray = myProjects.filter({ (project: Project) -> Bool in
            let matchedFName = project.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
            
            return matchedFName != nil
        })
    }
}




// MARK: - ANProjectDetailsVCDelegate

extension ANProjectsViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(project: Project) {
        print("projectEditingDidEndForProject")
    }
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectsViewController: ANNewProjectTableViewControllerDelegate {
    func projectDetailsVCDidCancel(controller: ANNewProjectTableViewController) {
        print("projectDetailsVCDidCancel")
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {
        print("projectDetailsVC didFinishAddingItem")
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {
        print("projectDetailsVC didFinishEditingItem")
        
    }
}






