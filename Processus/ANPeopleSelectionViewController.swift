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

        title = "Select Participants"
        
        let saveButton = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButton

    }
    
    // MARK: - HELPER METHODS
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let person = allPeople[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
        if project.workers!.containsObject(person) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
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
        
        let cellId = "PersonCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate

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
