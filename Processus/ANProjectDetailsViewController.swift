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
    
    var sectionsCount = 3
    var selectCellShowed = false
    
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
        
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    deinit {
        ANDataManager.sharedManager.saveContext()
        
        delegate?.projectEditingDidEndForProject(project)
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func refreshVCTitle() {
        title = "\(project.name!)"

    }
    
    func dueDateSoonForProject(project: Project) -> Bool {
        
        let currentDate = NSDate()
        
        let timeLeft = project.dueDate!.timeIntervalSinceDate(currentDate)
        print(timeLeft)
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600 && timeLeft > 0 {
            return true
        }
        
        return false
        
    }
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        

        cell.projectDueDateLabel.text = dateFormatter.stringFromDate(project.dueDate!)
        
        if let completedRatio = project.completedRatio?.intValue {
            cell.completedRatioLabel.text = "\(completedRatio) %"
        }

        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project)
        
    }
    
    func configurePersonCell(cell: ANPersonCell, atIndexPath indexPath: NSIndexPath) {
        
        let person = projectParticipants[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        cell.fullNameLabel.text = "\(firstName) \(lastName)"
        
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
            
            selectCellShowed = true
            sectionsCount = 4
            
            tableView.beginUpdates()
            
            tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
            
            let selectCellIndexP = NSIndexPath(forRow: 0, inSection: 2)
            
            let selectCell = tableView.cellForRowAtIndexPath(selectCellIndexP) as! ANProjectAddPersonCell
            
            ANAnimator.sharedAnimator.animateSelectRowView(selectCell.addPersonView)



            
        } else {
            buttonItem = .Edit
            
            selectCellShowed = false
            sectionsCount = 3
            
            tableView.beginUpdates()
            
            tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
            ANDataManager.sharedManager.saveContext()
        }
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonProject.rawValue:
            return 1
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return projectParticipants.count
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
        let cellIdPerson = "ANPersonCell"
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Separator.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdAddbutton, forIndexPath: indexPath) as! ANProjectAddPersonCell
            
            return cell
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPerson, forIndexPath: indexPath)  as! ANPersonCell
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell

        case ANSectionType.Person.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPerson, forIndexPath: indexPath)  as! ANPersonCell
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell
            
        default:
            
            let cell = UITableViewCell()
            return cell
            
        }
        
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            return 80
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.Person.rawValue:
            return 70
        default:
            break
            
        }

        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            return 80
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.Person.rawValue:
            return 70
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
            
        } else if indexPath.section == ANSectionType.Addbutton.rawValue && selectCellShowed {
        
//            transitToParticipantsSelection()
            
        
        } else if indexPath.section == ANSectionType.Person.rawValue || (indexPath.section == ANSectionType.Addbutton.rawValue && !selectCellShowed) {
            
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











