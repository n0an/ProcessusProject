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
    
    func participantsSelectionDidFinish(_ selectedParticipants: [Person])
    
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
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ANProjectSelectionViewController.savePressed(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButton

    }
    
    // MARK: - HELPER METHODS
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let person = allPeople[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        guard let cell = cell as? ANPersonCell else {return}
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData as Data)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        cell.fullNameLabel.text = "\(firstName) \(lastName)"
        
        
        if project.workers!.contains(person) {

            cell.checkMarkImageView.image = UIImage(named: "box_set")
        } else {

            cell.checkMarkImageView.image = UIImage(named: "box_empty")

        }
        
    }
    
    
    
    // MARK: - ACTIONS
    
    func savePressed(_ sender: UIBarButtonItem) {
        
        delegate?.participantsSelectionDidFinish(selectedPeople)
        
        self.dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return allPeople.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ANPersonCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let person = allPeople[indexPath.row]
        
        if project.workers!.contains(person) {
            
            project.removeFromWorkers(person)
            
//            project.remove(workerObject: person) // Swift 2 OLD
            
        } else {
            
            project.addToWorkers(person)
//            project.add(workerObject: person) // Swift 2 OLD
        }

        selectedPeople = project.workers?.allObjects as! [Person]
        
        tableView.reloadData()
        
    }
    
    
    
    

    
}
