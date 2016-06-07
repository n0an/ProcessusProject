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
        
        let finishedStatusDescriptor = NSSortDescriptor(key: "finishedStatus", ascending: false)
        
        fetchRequest.sortDescriptors = [finishedStatusDescriptor]
        
        let predicate = NSPredicate(format: "finished == true")
        
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: "finishedStatus", cacheName: nil)
        
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
        
        let cellColor: UIColor
        
        if project.finishedStatus == ProjectFinishedStatus.Success.rawValue {
            cellColor = UIColor(red: 143/255, green: 255/255, blue: 146/255, alpha: 0.3)
        } else {
            cellColor = UIColor(red: 255/255, green: 82/255, blue: 52/255, alpha: 0.3)
        }
        
        cell.backgroundColor = cellColor
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
            
            return sectionInfo.name
        }
        
        return nil
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        let paddingView = UIView()
        
        view.addSubview(paddingView)
        
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        
        let statusLabel = UILabel()
        paddingView.addSubview(statusLabel)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
            
            paddingView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            paddingView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraintEqualToAnchor(paddingView.centerXAnchor),
            statusLabel.centerYAnchor.constraintEqualToAnchor(paddingView.centerYAnchor),
            
            paddingView.heightAnchor.constraintEqualToAnchor(statusLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraintEqualToAnchor(statusLabel.widthAnchor, constant: 10),
            
            view.heightAnchor.constraintEqualToAnchor(paddingView.heightAnchor)
            
        ]
        
        NSLayoutConstraint.activateConstraints(constraints)
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {return nil}

        
        statusLabel.text = sectionInfo.name
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        
        
        
        let paddingViewBGColor: UIColor
        
        if sectionInfo.name == ProjectFinishedStatus.Success.rawValue {
            paddingViewBGColor = UIColor(red: 143/255, green: 255/255, blue: 146/255, alpha: 0.6)
        } else {
            paddingViewBGColor = UIColor(red: 255/255, green: 82/255, blue: 52/255, alpha: 0.6)

        }
        
        
        paddingView.backgroundColor = paddingViewBGColor

        
        return view
        
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
    
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showProjectDetails" {
            
            
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










