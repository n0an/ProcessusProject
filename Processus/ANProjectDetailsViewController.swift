//
//  ANProjectDetailsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 27/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

protocol ANProjectDetailsVCDelegate: class {
    func projectEditingDidEndForProject(project: Project)
}

class ANProjectDetailsViewController: UITableViewController {

    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case PersonProject = 0
        case Separator
        case Addbutton
        case Person
    }
    
    var isEditingMode = false

    var project: Project!
    
    var projectParticipants: [Person] = []
    
    weak var delegate: ANProjectDetailsVCDelegate?
    
    var dateFormatter: NSDateFormatter!

    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshVCTitle()
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        let rightButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        
    }
    
    deinit {
        ANDataManager.sharedManager.saveContext()
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func refreshVCTitle() {
        title = "\(project.name!)"

    }
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        cell.projectDueDateLabel.text = dateFormatter.stringFromDate(project.dueDate!)

        
        if let completedRatio = project.completedRatio?.intValue {
            cell.completedRatioLabel.text = "\(completedRatio) %"
        }
        
        var stateColor = UIColor()
        
        switch project.state!.integerValue {
        case ANProjectState.NonActive.rawValue:
            stateColor = UIColor.redColor()
        case ANProjectState.Frozen.rawValue:
            stateColor = UIColor.yellowColor()
        case ANProjectState.Active.rawValue:
            stateColor = UIColor.greenColor()
        default:
            break
        }
        
        cell.projectStateView.backgroundColor = stateColor
        
    }
    
    func configurePersonCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let person = projectParticipants[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        
    }
    
    func transitToParticipantsSelection() {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]
        
        let context = ANDataManager.sharedManager.context
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANPeopleSelectionViewController") as! ANPeopleSelectionViewController
        
        vc.project = project
        vc.selectedPeople = projectParticipants
        vc.delegate = self
        
        do {
            let allPeople = try context.executeFetchRequest(fetchRequest) as! [Person]
            
            vc.allPeople = allPeople
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        print("addButtonPressed")
        
        transitToParticipantsSelection()
    }
    
    func editPressed(sender: UIBarButtonItem) {
        
        tableView.setEditing(!isEditingMode, animated: true)
        isEditingMode = !isEditingMode
        
        var buttonItem: UIBarButtonSystemItem
        
        if isEditingMode {
            buttonItem = .Done
            
        } else {
            buttonItem = .Edit
            
            ANDataManager.sharedManager.saveContext()
        }
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonProject.rawValue:
            return 1
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.Addbutton.rawValue:
            return 1
        case ANSectionType.Person.rawValue:
            return projectParticipants.count
        default:
            break
        }
        
        return 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdPersonProject = "personProjectsCell"
        let cellIdSeparator = "separatorCell"
        let cellIdAddbutton = "AddCell"
        let cellIdPerson = "PersonCell"
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Separator.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Addbutton.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdAddbutton, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Person.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPerson, forIndexPath: indexPath)
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell
            
        default:
            
            let cell = UITableViewCell()
            return cell
            
        }
        
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == ANSectionType.Separator.rawValue {
            return 2
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            return 80
        case ANSectionType.Separator.rawValue:
            return 2
        case ANSectionType.Addbutton.rawValue:
            return 44
        case ANSectionType.Person.rawValue:
            return 44
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == ANSectionType.PersonProject.rawValue {
            
            // === Variant - instantiate ANEditProjectTableViewController ===
            /*
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANEditProjectTableViewController") as! ANEditProjectTableViewController
            
            vc.delegate = self
            
            vc.itemToEdit = project
            
            navigationController?.pushViewController(vc, animated: true)
            */
            
            performSegueWithIdentifier("EditItem", sender: self)
            
        } else if indexPath.section == ANSectionType.Addbutton.rawValue {
        
            transitToParticipantsSelection()
            
        } else if indexPath.section == ANSectionType.Person.rawValue {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANPersonDetailsViewController") as! ANPersonDetailsViewController
            
            vc.person = projectParticipants[indexPath.row] as Person
            
            vc.delegate = self
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section != ANSectionType.Person.rawValue  {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let person = projectParticipants[indexPath.row]
            
            project.remove(workerObject: person)
            
            projectParticipants = project.workers?.allObjects as! [Person]
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
        }
    }
    
    
    
    // MARK: - SEGUES
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EditItem" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.itemToEdit = project
            
            controller.delegate = self

        }
    }
    
    
}



// MARK: - ANPeopleSelectionViewControllerDelegate

extension ANProjectDetailsViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(selectedParticipants: [Person]) {
        
        projectParticipants = selectedParticipants
        
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
        
    }
    
}


// === Variant - instantiate ANEditProjectTableViewController ===
/*
// MARK: - ANEditProjectTableViewControllerDelegate

extension ANProjectDetailsViewController: ANEditProjectTableViewControllerDelegate {
    
    func projectEditingDidEndForProject(project: Project) {
        
        tableView.reloadData()
    }
    
}
*/

extension ANProjectDetailsViewController: ANNewProjectTableViewControllerDelegate {
    
    func projectDetailsVCDidCancel(controller: ANNewProjectTableViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {
        
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        tableView.reloadData()
    }

}



extension ANProjectDetailsViewController: ANPersonDetailsVCDelegate {
    
    func personEditingDidEndForPerson(person: Person) {
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        refreshVCTitle()
        
        tableView.reloadData()
        
        ANDataManager.sharedManager.saveContext()
        
    }

}











