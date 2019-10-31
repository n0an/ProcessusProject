//
//  ANProjectsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData
//import Parse


class ANProjectsViewController: UIViewController {

    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - ATTRIBUTES
    
    var searchController: UISearchController!

    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    var searchResultsArray: [Project] = []
    
    var myProjects: [Project] = []
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
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
        searchController.searchBar.tintColor = UIColor.white

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // jumping toolBar issue fixed
        tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: view.bounds.maxY - (tabBarController?.tabBar.frame.height)!)

    }
    
    
    
    // MARK: - HELPER METHODS
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func unwindBackToHomeScreen(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func addProjectPressed(_ sender: UIBarButtonItem) {
        
        
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.delegate = self
            
        } else if segue.identifier == "showProjectDetails" {
            
            
            let destinationVC = segue.destination as! ANProjectDetailsViewController
            
            destinationVC.delegate = self
            
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            guard let project = fetchedResultsController?.object(at: indexPath) as? Project else {return}
            
            destinationVC.project = project
            
        }
        
        
    }


}




// MARK: - UITableViewDataSource
extension ANProjectsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return searchResultsArray.count
        }
        
        return myProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ANPersonProjectCell
        
        
        let project = searchController.isActive ? searchResultsArray[indexPath.row] : myProjects[indexPath.row]
        
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate! as Date)
        
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)
        
     
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANProjectsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive {
            return false
        }
        
        return true
    }

    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let finishAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("ACTION_FINISH_TITLE", comment: "")) { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let finishActionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let finishSuccessAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_SUCCESS_ACTION", comment: ""), style: .default) { (action: UIAlertAction) in
                
                let projectToFinish = self.fetchedResultsController.object(at: indexPath) as! Project
                
                projectToFinish.state = ANProjectState.nonActive.rawValue as NSNumber
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Success.rawValue
                
                ANDataManager.sharedManager.saveContext()
            }
            
            

            let finishFailureAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_FAILURE_ACTION", comment: ""), style: .default, handler: { (action: UIAlertAction) in
                
                let projectToFinish = self.fetchedResultsController.object(at: indexPath) as! Project
                
                projectToFinish.state = ANProjectState.nonActive.rawValue as NSNumber
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Failure.rawValue
                
                ANDataManager.sharedManager.saveContext()
            })
            
            

            let cancelAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_CANCEL_ACTION", comment: ""), style: .cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            finishActionMenu.addAction(finishFailureAction)

            finishActionMenu.addAction(cancelAction)
            
            
            self.present(finishActionMenu, animated: true, completion: nil)
        }
        
        // Creating our own Delete button
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: NSLocalizedString("DELETE_ACTION", comment: "")) { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ALERT_MESSAGE", comment: ""), style: AlertStyle.warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("DELETE_PROJECT_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    
                }
                else {
                    
                    let projectToRemove = self.fetchedResultsController.object(at: indexPath) as! Project
                    
                    
                    let managedObjectContext = ANDataManager.sharedManager.context
                    
                    managedObjectContext.delete(projectToRemove)
                    
                    if managedObjectContext.hasChanges {
                        do {
                            try managedObjectContext.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                            abort()
                        }
                    }
                    
                    SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ACTION_RESULT_TITLE", comment: ""), style: AlertStyle.success)
                }
            }
            
        }
        
        finishAction.backgroundColor = UIColor(red: 50/255, green: 70/255, blue: 181/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction, finishAction]
        
    }
    
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension ANProjectsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            tableView.reloadData()
        }
        
        myProjects = controller.fetchedObjects as! [Project]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}




// MARK: - UISearchResultsUpdating

extension ANProjectsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContentFor(searchText!)
        
        tableView.reloadData()
    }
    
    func filterContentFor(_ searchText: String) {
        
        searchResultsArray = myProjects.filter({ (project: Project) -> Bool in
            let matchedFName = project.fullName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            
            return matchedFName != nil
        })
    }
}




// MARK: - ANProjectDetailsVCDelegate

extension ANProjectsViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(_ project: Project) {
        
    }
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectsViewController: ANNewProjectTableViewControllerDelegate {
    func projectDetailsVCDidCancel(_ controller: ANNewProjectTableViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {
        
        
    }
}






