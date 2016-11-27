//
//  ANPeopleViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 12/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

import MessageUI

class ANPeopleViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ATTRIBUTES
    
    var searchController: UISearchController!
    
    var searchResultsArray: [Person] = []
    
    var myColleagues: [Person] = []
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        

        
        // Loading data from DB
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: ANDataManager.sharedManager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            print("There was a problem fetching.")
        }
        
        
        myColleagues = fetchedResultsController.fetchedObjects as! [Person]
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true 
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.white
        
        
    }
    
    // MARK: - HELPER METHODS
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addColleaguePressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "showPersonDetails" else {return}
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        let destinationVC = segue.destination as! ANPersonDetailsViewController

 
        destinationVC.delegate = self
        
        destinationVC.person = searchController.isActive ? searchResultsArray[indexPath.row] : myColleagues[indexPath.row]
        
    }
    
}


// MARK: - UITableViewDataSource
extension ANPeopleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return searchResultsArray.count
        }
        
        return myColleagues.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ANPersonCell
        
        
        let person = searchController.isActive ? searchResultsArray[indexPath.row] : myColleagues[indexPath.row]
        
        
        if let firstName = person.firstName, let lastName = person.lastName {
            cell.fullNameLabel.text = "\(firstName) \(lastName)"

        }
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData as Data)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANPeopleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if searchController.isActive {
            return false
        }
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let allShareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Email") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            let personToContact = self.fetchedResultsController.object(at: indexPath) as! Person
            
            if let emailTo = personToContact.email {
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeVC = MFMailComposeViewController()
                    
                    mailComposeVC.mailComposeDelegate = self
                    mailComposeVC.setToRecipients([emailTo])
                    
                    let subjectSuffix: String
                    let personName = personToContact.firstName
                    if personName != nil {
                        subjectSuffix = ", \(personName!)!"
                    } else {
                        subjectSuffix = "!"
                    }
                    
                    
                    mailComposeVC.setSubject(NSLocalizedString("EMAIL_SUBJECT", comment: "") + subjectSuffix)
                    
                    self.present(mailComposeVC, animated: true, completion: {
                    })
                    
                    
                }
            }

            
        }
        
        // Creating our own Delete button
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: NSLocalizedString("DELETE_ACTION", comment: "")) { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            
            SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("DELETE_ALERT_MESSAGE", comment: ""), style: AlertStyle.warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("DELETE_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
//                    print("Cancel Button  Pressed", terminator: "")
                }
                else {
                    
                    let personToRemove = self.fetchedResultsController.object(at: indexPath) as! Person
                    
                    
                    let managedObjectContext = ANDataManager.sharedManager.context
                    
                    managedObjectContext.delete(personToRemove)
                    
                    if managedObjectContext.hasChanges {
                        do {
                            try managedObjectContext.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                            abort()
                        }
                    }

                    
                    SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("DELETE_ACTION_RESULT_TITLE", comment: ""), style: AlertStyle.success)
                }
            }

            
        }
        
        allShareAction.backgroundColor = UIColor(red: 184/255, green: 226/255, blue: 181/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction, allShareAction]
        
    }
    
}



// MARK: - NSFetchedResultsControllerDelegate

extension ANPeopleViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            tableView.reloadData()
        }
        
        myColleagues = controller.fetchedObjects as! [Person]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


// MARK: - UISearchResultsUpdating

extension ANPeopleViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContentFor(searchText!)
        
        tableView.reloadData()
    }
    
    func filterContentFor(_ searchText: String) {
        
        searchResultsArray = myColleagues.filter({ (person: Person) -> Bool in
            let matchedFName = person.fullName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
            
            return matchedFName != nil
        })
        
    }

    
    
}

// MARK: - ANPersonDetailsVCDelegate

extension ANPeopleViewController: ANPersonDetailsVCDelegate {
    func personEditingDidEndForPerson(_ person: Person) {
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
    }
    
}




extension ANPeopleViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.saved.rawValue:
            print("Message saved")
        case MFMailComposeResult.cancelled.rawValue:
            print("Message canceled")
        case MFMailComposeResult.sent.rawValue:
            print("Message was sent")
        case MFMailComposeResult.failed.rawValue:
            print("Message was not sent: \(error?.localizedDescription)")
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    
}




















