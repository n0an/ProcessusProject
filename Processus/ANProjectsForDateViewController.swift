//
//  ANProjectsForDateViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 02/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

enum ANDateIterationDirection {
    case Previous
    case Next
}

protocol ANProjectsForDateViewControllerDelegate: class {
    
    func iterateDateWithDirection(direction: ANDateIterationDirection) -> (date: NSDate, projects: [Project])
    
    func refreshDate() -> [Project]
    
}

class ANProjectsForDateViewController: UIViewController {
    

    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noProjectsLabel: UILabel!
    
    
    // MARK: - ATTRIBUTES
    
    let calend = ANConfigurator.sharedConfigurator.calendar

    var myProjects: [Project]!
    
    var displayedDate: NSDate!
    
    weak var delegate: ANProjectsForDateViewControllerDelegate!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }

    
    // MARK: - HELPER METHODS

    func dueDateSoonForProject(project: Project) -> Bool {
        
        let currentDate = NSDate()
        
        let timeLeft = project.dueDate!.timeIntervalSinceDate(currentDate)
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600 && timeLeft > 0 {
            return true
        }
        
        return false
        
    }
    
    func iterateDateWithDirection(direction: ANDateIterationDirection) {
        
        
        let dateProjectsTuple = self.delegate.iterateDateWithDirection(direction)
        
        myProjects = dateProjectsTuple.projects
        displayedDate = dateProjectsTuple.date
        
        updateView()

    }
    
    func updateView() {
        
        let stringDate = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(displayedDate)
        
        title = "\(stringDate)"
        
        
        if myProjects.isEmpty {
            noProjectsLabel.hidden = false
            tableView.hidden = true
        } else {
            noProjectsLabel.hidden = true
            tableView.hidden = false
            tableView.reloadData()
        }

    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func actionNextPressed(button: UIBarButtonItem) {
        iterateDateWithDirection(.Next)
    }
    
    @IBAction func actionPreviousPressed(button: UIBarButtonItem) {
        iterateDateWithDirection(.Previous)
    }


    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.delegate = self
            
            controller.dueDate = displayedDate
            
        } else if segue.identifier == "showProjectDetails" {
            
            
            let destinationVC = segue.destinationViewController as! ANProjectDetailsViewController
            
            destinationVC.delegate = self
            
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            let project = myProjects[indexPath.row]
            
            destinationVC.project = project
            
        }
        
        
    }
    
    


}



// MARK: - UITableViewDataSource
extension ANProjectsForDateViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myProjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ANPersonProjectCell
        
        
        let project = myProjects[indexPath.row]
        
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(project.dueDate!)
        
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANProjectsForDateViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let project = myProjects[indexPath.row]

        if editingStyle == .Delete {
            let context = ANDataManager.sharedManager.context
            context.deleteObject(project)
            
            ANDataManager.sharedManager.saveContext()
            
            myProjects.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
            updateView()
            
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        
        return true
    }

    
    
}




// MARK: - ANProjectDetailsVCDelegate

extension ANProjectsForDateViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(project: Project) {
        
        myProjects = delegate.refreshDate()
        
        updateView()
        
    }
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectsForDateViewController: ANNewProjectTableViewControllerDelegate {
    func projectDetailsVCDidCancel(controller: ANNewProjectTableViewController) {

        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {

        controller.dismissViewControllerAnimated(true, completion: nil)
        
        myProjects = delegate.refreshDate()

        updateView()

    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {

        
    }
}









