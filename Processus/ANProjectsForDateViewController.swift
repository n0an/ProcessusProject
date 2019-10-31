//
//  ANProjectsForDateViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 02/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

enum ANDateIterationDirection {
    case previous
    case next
}

protocol ANProjectsForDateViewControllerDelegate: class {
    
    func iterateDateWithDirection(_ direction: ANDateIterationDirection) -> (date: Date, projects: [Project])
    
    func refreshDate() -> [Project]
    
}

class ANProjectsForDateViewController: UIViewController {
    

    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noProjectsLabel: UILabel!
    
    
    // MARK: - ATTRIBUTES
    
    let calend = ANConfigurator.sharedConfigurator.calendar

    var myProjects: [Project]!
    
    var displayedDate: Date!
    
    weak var delegate: ANProjectsForDateViewControllerDelegate!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }

    
    // MARK: - HELPER METHODS

    func dueDateSoonForProject(_ project: Project) -> Bool {
        
        let currentDate = Date()
        
        let timeLeft = project.dueDate!.timeIntervalSince(currentDate)
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600 && timeLeft > 0 {
            return true
        }
        
        return false
        
    }
    
    func iterateDateWithDirection(_ direction: ANDateIterationDirection) {
        
        
        let dateProjectsTuple = self.delegate.iterateDateWithDirection(direction)
        
        myProjects = dateProjectsTuple.projects
        displayedDate = dateProjectsTuple.date
        
        updateView()

    }
    
    func updateView() {
        
        let stringDate = ANConfigurator.sharedConfigurator.dateFormatter.string(from: displayedDate)
        
        title = "\(stringDate)"
        
        
        if myProjects.isEmpty {
            noProjectsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noProjectsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }

    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func actionNextPressed(_ button: UIBarButtonItem) {
        iterateDateWithDirection(.next)
    }
    
    @IBAction func actionPreviousPressed(_ button: UIBarButtonItem) {
        iterateDateWithDirection(.previous)
    }


    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.delegate = self
            
            controller.dueDate = displayedDate
            
        } else if segue.identifier == "showProjectDetails" {
            
            
            let destinationVC = segue.destination as! ANProjectDetailsViewController
            
            destinationVC.delegate = self
            
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            let project = myProjects[indexPath.row]
            
            destinationVC.project = project
            
        }
        
        
    }
    
    


}



// MARK: - UITableViewDataSource
extension ANProjectsForDateViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "personProjectsCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ANPersonProjectCell
        
        
        let project = myProjects[indexPath.row]
        
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate! as Date)
        
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANProjectsForDateViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let project = myProjects[indexPath.row]

        if editingStyle == .delete {
            let context = ANDataManager.sharedManager.context
            context.delete(project)
            
            ANDataManager.sharedManager.saveContext()
            
            myProjects.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
            
            updateView()
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        
        return true
    }

    
    
}




// MARK: - ANProjectDetailsVCDelegate

extension ANProjectsForDateViewController: ANProjectDetailsVCDelegate {
    func projectEditingDidEndForProject(_ project: Project) {
        
        myProjects = delegate.refreshDate()
        
        updateView()
        
    }
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectsForDateViewController: ANNewProjectTableViewControllerDelegate {
    func projectDetailsVCDidCancel(_ controller: ANNewProjectTableViewController) {

        controller.dismiss(animated: true, completion: nil)
    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {

        controller.dismiss(animated: true, completion: nil)
        
        myProjects = delegate.refreshDate()

        updateView()

    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {

        
    }
}









