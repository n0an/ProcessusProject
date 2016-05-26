//
//  ANProjectSelectionViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 25/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


protocol ANProjectSelectionViewControllerDelegate {
    
    func projectSelectionDidFinish(selectedProject: [Project])
    
}


class ANProjectSelectionViewController: UITableViewController {

    var allProjects: [Project]!
    
    var selectedProjects: [Project]!
    
    var person: Person!
    
    
    var delegate: ANProjectSelectionViewControllerDelegate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("incoming person = \(person.firstName) \(person.lastName)")
        
        print("allProjects = \(allProjects)")
        
        print("selectedProjects = \(selectedProjects)")
        
        ANDataManager.sharedManager.showAllProjects()
        
        
        
        let saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        
        let project = allProjects[indexPath.row]
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        
        if let completedRatio = project.completedRatio?.intValue {
//            cell.completedRatioLabel.text = "10"
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
        
        for project in person.projects! {
            print(project.customer)
        }
        
        
        if (person.projects!.containsObject(project)) {
            
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        
    }

    
    
    
    
    // MARK: - ACTIONS
    
    func savePressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allProjects.count
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdPersonProject = "personProjectsCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
        
        configurePersonProjectCell(cell, forIndexPath: indexPath)
        
        return cell
        
        
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let project = allProjects[indexPath.row]
        
        
        if (person.projects!.containsObject(project)) {
            person.remove(projectObject: project)
        } else {
            person.add(projectObject: project)
        }
        
        selectedProjects = person.projects?.allObjects as! [Project]
        
        tableView.reloadData()
        
    }
    

}















