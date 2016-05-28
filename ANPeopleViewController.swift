//
//  ANPeopleViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class ANPeopleViewController: UIViewController, ANTableViewFetchedResultsDisplayer {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ATTRIBUTES
    
    var myColleagues: [Person] = []
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsDelegate = ANTableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
        
        fetchedResultsController?.delegate = fetchedResultsDelegate
        
        do {
            try fetchedResultsController?.performFetch()
            
        } catch {
            print("There was a problem fetching.")
        }
        
        /*
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            try myColleagues = ANDataManager.sharedManager.context.executeFetchRequest(fetchRequest) as! [Person]

        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        */
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addColleaguePressed(sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: - HELPER METHODS
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        guard let person = fetchedResultsController?.objectAtIndexPath(indexPath) as? Person else {return}
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "showPersonDetails" else {return}
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        guard let person = fetchedResultsController?.objectAtIndexPath(indexPath) as? Person else {return}
        
        let destinationVC = segue.destinationViewController as! ANPersonDetailsViewController
        
        destinationVC.delegate = self
        
        destinationVC.person = person
        
    }
    
}


// MARK: - UITableViewDataSource
extension ANPeopleViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {return 0}
        
        let currentSection = sections[section]
        
        return currentSection.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "PersonCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANPeopleViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let person = fetchedResultsController?.objectAtIndexPath(indexPath) as? Person else {return}
        
        if editingStyle == .Delete {
            let context = ANDataManager.sharedManager.context
            context.deleteObject(person)
            
            ANDataManager.sharedManager.saveContext()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        
    }
    
}



extension ANPeopleViewController: ANPersonDetailsVCDelegate {
    func personEditingDidEndForPerson(person: Person) {
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
    }

}








