//
//  ANPeopleViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class ANPeopleViewController: UIViewController, UITextFieldDelegate, ANTableViewFetchedResultsDisplayer {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var myColleagues: [Person] = []
    
    private var fetchedResultsController: NSFetchedResultsController?
    
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?

    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]

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
    
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        
        
        
        guard let person = fetchedResultsController?.objectAtIndexPath(indexPath) as? Person else {return}
        
        guard let firstName = person.firstName else {return}
        
        guard let lastName = person.lastName else {return}
        
        
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
        
        
    }

    
    
    
    
    @IBAction func addColleaguePressed(sender: UIBarButtonItem) {
        
        let addColleagueAlert = UIAlertController(title: "Добавить коллегу", message: "Введите имя, фамилию, телефон и email", preferredStyle: .Alert)
        
        addColleagueAlert.addTextFieldWithConfigurationHandler { (tField) in
            tField.placeholder = "Введите имя"
            tField.delegate = self
            self.configureTextFieldNames(tField)
        }
        
        addColleagueAlert.addTextFieldWithConfigurationHandler { (tField) in
            tField.placeholder = "Введите фамилию"
            tField.delegate = self
            self.configureTextFieldNames(tField)

        }
        
        addColleagueAlert.addTextFieldWithConfigurationHandler { (tField) in
            tField.placeholder = "Введите email"
            tField.delegate = self
            tField.tag = 108
            
            tField.returnKeyType = .Done
            
            tField.spellCheckingType = .No
            tField.autocorrectionType = .No
            tField.autocapitalizationType = .None
            tField.keyboardType = .EmailAddress
            
        }
        
//        addColleagueAlert.addTextFieldWithConfigurationHandler { (tField) in
//            tField.placeholder = "Введите номер телефона"
//            tField.delegate = self
//        }
        
        
        let addAction = UIAlertAction(title: "Добавить", style: .Default) { action in
            
            let textFieldFirstName = addColleagueAlert.textFields?[0]
            let colleagueFirstName = textFieldFirstName?.text
            
            let textFieldLastName = addColleagueAlert.textFields?[1]
            let colleagueLastName = textFieldLastName?.text
            
            let textFieldEmail = addColleagueAlert.textFields?[2]
            let colleagueEmail = textFieldEmail?.text
            
            
            if colleagueFirstName?.characters.count > 0 && colleagueLastName?.characters.count > 0 && colleagueEmail?.characters.count > 0 {
                
                ANDataManager.sharedManager.addPerson(withFirstName: colleagueFirstName!, lastName: colleagueLastName!, email: colleagueEmail!)
                
            } else {
                print("Empty fields")
            }
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel, handler: nil)
        
        addColleagueAlert.addAction(addAction)
        addColleagueAlert.addAction(cancelAction)
        
        self.presentViewController(addColleagueAlert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    
    
    // MARK: - Helper Methods
    
    
    func configureTextFieldNames(textField: UITextField) {
        textField.spellCheckingType = .No
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .Words
        textField.keyboardType = .Default
    }
    
    
    
    // TODO: - emailHandler
    

}



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
        
//        let colleague = myColleagues[indexPath.row]
//        
//        cell.textLabel?.text = colleague.firstName! + colleague.lastName!
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
}