//
//  ANProjectSelectionViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 25/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


protocol ANProjectSelectionViewControllerDelegate: class {
    
    func projectSelectionDidFinish(_ selectedProjects: [Project])
    
}


class ANProjectSelectionViewController: UITableViewController {

    // MARK: - ATTRIBUTES
    
    var allProjects: [Project]!
    
    var selectedProjects: [Project]!
    
    var person: Person!
    
    weak var delegate: ANProjectSelectionViewControllerDelegate!
    

    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("PROJECTSELECTIONVC_TITLE", comment: "")
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
    }
    
    
    // MARK: - HELPER METHODS
    
    
    func configurePersonProjectCell(_ cell: ANPersonProjectCell, forIndexPath indexPath: IndexPath) {
        
        let project = allProjects[indexPath.row]

        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate! as Date)
        
        if (person.projects!.contains(project)) {

            cell.checkMarkImageView.image = UIImage(named: "box_set")
            
        } else {

            cell.checkMarkImageView.image = UIImage(named: "box_empty")

        }
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)
        
    }

    
    // MARK: - ACTIONS
    
    func savePressed(_ sender: UIBarButtonItem) {
        
        delegate.projectSelectionDidFinish(selectedProjects)
        
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allProjects.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdPersonProject = "personProjectsCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPersonProject, for: indexPath) as! ANPersonProjectCell
        
        configurePersonProjectCell(cell, forIndexPath: indexPath)
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let project = allProjects[indexPath.row]
        
        
        if (person.projects!.contains(project)) {
            person.removeFromProjects(project)
//            person.remove(projectObject: project) // Swift 2 OLD
        } else {
            person.addToProjects(project)
//            person.add(projectObject: project) // Swift 2 OLD
        }
        
        selectedProjects = person.projects?.allObjects as! [Project]
        
        tableView.reloadData()
        
    }
    

}















