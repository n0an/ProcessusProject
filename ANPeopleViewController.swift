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
    
    private var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
//        navigationItem.leftBarButtonItem = editButtonItem()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
//        tableView.tableFooterView = UIView(frame: CGRectZero) // FAIL WITH SEARCHCONTROLLER
        
        
        
        // Loading data from DB
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
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
        
        myColleagues = fetchedResultsController.fetchedObjects as! [Person]
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
        
        definesPresentationContext = true 
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.whiteColor()
        
        
    }
    
    // MARK: - HELPER METHODS
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addColleaguePressed(sender: UIBarButtonItem) {
        
    }
    
    
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard segue.identifier == "showPersonDetails" else {return}
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
        
        let destinationVC = segue.destinationViewController as! ANPersonDetailsViewController

 
        destinationVC.delegate = self
        
        destinationVC.person = searchController.active ? searchResultsArray[indexPath.row] : myColleagues[indexPath.row]
        
    }
    
}


// MARK: - UITableViewDataSource
extension ANPeopleViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active {
            return searchResultsArray.count
        }
        
        return myColleagues.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellId = "ANPersonCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ANPersonCell
        
        
        let person = searchController.active ? searchResultsArray[indexPath.row] : myColleagues[indexPath.row]
        
        
        if let firstName = person.firstName, lastName = person.lastName {
            cell.fullNameLabel.text = "\(firstName) \(lastName)"

        }
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        
        return cell
    }
    
}


// MARK: - UITableViewDelegate

extension ANPeopleViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if searchController.active {
            return false
        }
        
        return true
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let allShareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Email") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            let personToContact = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Person
            
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
                    
                    
                    mailComposeVC.setSubject("Hey" + subjectSuffix)
                    
                    
//                    mailComposeVC.navigationBar.tintColor = UIColor.whiteColor()
                    
                    self.presentViewController(mailComposeVC, animated: true, completion: {
                        //                    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
                    })
                    
                    
                }
            }

            
            // Contact ways for future releases
            /*
            let allShareActionMenu = UIAlertController(title: nil, message: "Contact with", preferredStyle: .ActionSheet)
            
            let emailShareAction = UIAlertAction(title: "Email", style: .Default, handler: nil)
            let facebookShareAction = UIAlertAction(title: "Facebook", style: .Default, handler: nil)
            let vkShareAction = UIAlertAction(title: "VK", style: .Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            allShareActionMenu.addAction(emailShareAction)
            allShareActionMenu.addAction(facebookShareAction)
            allShareActionMenu.addAction(vkShareAction)
            allShareActionMenu.addAction(cancelAction)
            
            
            self.presentViewController(allShareActionMenu, animated: true, completion: nil)
            */
        }
        
        // Creating our own Delete button
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            
            
            
            
            SweetAlert().showAlert("Are you sure?", subTitle: "Contact will be permanently removed!", style: AlertStyle.Warning, buttonTitle:"Cancel", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, remove please", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if isOtherButton == true {
                    
                    print("Cancel Button  Pressed", terminator: "")
                }
                else {
                    
                    let personToRemove = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Person
                    
                    
                    let managedObjectContext = ANDataManager.sharedManager.context
                    
                    managedObjectContext.deleteObject(personToRemove)
                    
                    if managedObjectContext.hasChanges {
                        do {
                            try managedObjectContext.save()
                        } catch {
                            let nserror = error as NSError
                            NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                            abort()
                        }
                    }

                    
                    SweetAlert().showAlert("Deleted!", subTitle: "Contact has been removed", style: AlertStyle.Success)
                }
            }

            
        }
        
        allShareAction.backgroundColor = UIColor(red: 184/255, green: 226/255, blue: 181/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction, allShareAction]
        
    }
    
}



// MARK: - NSFetchedResultsControllerDelegate

extension ANPeopleViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            tableView.reloadData()
        }
        
        myColleagues = controller.fetchedObjects as! [Person]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}


// MARK: - UISearchResultsUpdating

extension ANPeopleViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        filterContentFor(searchText!)
        
        tableView.reloadData()
    }
    
    func filterContentFor(searchText: String) {
        
        searchResultsArray = myColleagues.filter({ (person: Person) -> Bool in
            let matchedFName = person.fullName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil, locale: nil)
            
            return matchedFName != nil
        })
        
    }

    
    
}

// MARK: - ANPersonDetailsVCDelegate

extension ANPeopleViewController: ANPersonDetailsVCDelegate {
    func personEditingDidEndForPerson(person: Person) {
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
    }
    
}




extension ANPeopleViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultSaved.rawValue:
            print("Message saved")
        case MFMailComposeResultCancelled.rawValue:
            print("Message canceled")
        case MFMailComposeResultSent.rawValue:
            print("Message was sent")
        case MFMailComposeResultFailed.rawValue:
            print("Message was not sent: \(error?.localizedDescription)")
        default:
            break
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    
}




















