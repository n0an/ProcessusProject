//
//  ANPeopleSelectionViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 26/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData


protocol ANPeopleSelectionViewControllerDelegate: class {
    
    func participantsSelectionDidFinish(selectedParticipants: [Person])
    
}


class ANPeopleSelectionViewController: UIViewController {
    
    // MARK: - OUTLETS

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ATTRIBUTES
    
    var allPeople: [Person]!
    
    var selectedPeople: [Person]!
    
    var project: Project!

    weak var delegate: ANPeopleSelectionViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("PEOPLESELECTIONVC_TITLE", comment: "")
        
//        let saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButton

    }
    
    // MARK: - HELPER METHODS
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let person = allPeople[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        guard let cell = cell as? ANPersonCell else {return}
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        cell.fullNameLabel.text = "\(firstName) \(lastName)"
        
        
        if project.workers!.containsObject(person) {
//            cell.accessoryType = .Checkmark
            cell.checkMarkImageView.image = UIImage(named: "box_set")
        } else {
//            cell.accessoryType = .None
            cell.checkMarkImageView.image = UIImage(named: "box_empty")

        }
        
    }
    
    
    
    // MARK: - ACTIONS
    
    func savePressed(sender: UIBarButtonItem) {
        
        delegate?.participantsSelectionDidFinish(selectedPeople)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allPeople.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ANPersonCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let person = allPeople[indexPath.row]
        
        if project.workers!.containsObject(person) {
            
            project.remove(workerObject: person)
            
        } else {
            project.add(workerObject: person)
        }

        selectedPeople = project.workers?.allObjects as! [Person]
        
        tableView.reloadData()
        
    }
    
    
    
    

    
}
