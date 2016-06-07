//
//  ANFinishedProjetsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 07/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


class ANFinishedProjetsViewController: UIViewController, ANTableViewFetchedResultsDisplayer {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ATTRIBUTES
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        
        let fetchRequest = NSFetchRequest(entityName: "Project")
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        let predicate = NSPredicate(format: "finished == true")
        
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: "finishedSuccess", cacheName: nil)
        
        fetchedResultsDelegate = ANTableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
        
        fetchedResultsController?.delegate = fetchedResultsDelegate
        
        do {
            try fetchedResultsController?.performFetch()
            
        } catch {
            print("There was a problem fetching.")
        }
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        guard let cell = cell as? ANPersonProjectCell else {return}
        
        guard let project = fetchedResultsController?.objectAtIndexPath(indexPath) as? Project else {return}
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(project.dueDate!)
        
        //        if let completedRatio = project.completedRatio?.intValue {
        //            cell.completedRatioLabel.text = "\(completedRatio) %"
        //        }
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        var stateColor = UIColor()
        
        switch project.state!.integerValue {
        case ANProjectState.NonActive.rawValue:
            stateColor = UIColor.redColor()
        case ANProjectState.Frozen.rawValue:
            stateColor = UIColor.yellowColor()
        case ANProjectState.Active.rawValue:
            stateColor = UIColor.greenColor()
        default:
            break
        }
        
        cell.projectStateView.backgroundColor = stateColor
        
    }
    
    
    // MARK: - ACTIONS
    
    
    
    
}




// MARK: - UITableViewDataSource
extension ANFinishedProjetsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {return 0}
        
        let currentSection = sections[section]
        
        return currentSection.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sectionInfo = fetchedResultsController?.sections?[section] {
            
            if sectionInfo.name == "0" {
                return "Failure"
            }
            
            if sectionInfo.name == "1" {
                return "Success"
            }
            
        }
        
        return nil
        
        
    }
    
}


// MARK: - UITableViewDelegate

extension ANFinishedProjetsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let project = fetchedResultsController?.objectAtIndexPath(indexPath) as? Project else {return}
        
        if editingStyle == .Delete {
            let context = ANDataManager.sharedManager.context
            context.deleteObject(project)
            
            ANDataManager.sharedManager.saveContext()
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //        guard let project = fetchedResultsController?.objectAtIndexPath(indexPath) as? Project else {return}
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    
    // MARK: - SEGUES
    
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



// MARK: - ANProjectDetailsVCDelegate

extension ANFinishedProjetsViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(project: Project) {
        print("projectEditingDidEndForProject")
    }
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANFinishedProjetsViewController: ANNewProjectTableViewControllerDelegate {
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







